import Foundation
import PBSwift


enum ReplyBody {
    static var jsonEncoder = JSONEncoder.sorted()
    
    case json(Encodable)//url
    case string(String)
    func data() throws -> Data {
        switch self {
        case .json(let obj):
            return try Self.jsonEncoder.encode(obj)
        case .string(let str):
            return str.data(using: .utf8)!
        }
    }
}
struct RequestMock {
    var method: String?
    var url: String?
    var body: [String: Any]?
    var additionalMatcher: ((URLRequest) -> Bool)?
    var delay: Int?
    var replyCode: Int?
    var replyBody: ReplyBody?
}

func dummyJWT(payload: [String: Any] = [:]) -> String {
    let data = try! JSONSerialization.data(withJSONObject: payload)
    let base64String = data.base64EncodedString()
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9." + base64String + ".test"
}

class FetchMock {
    private var originalFetch: FetchCompletion!
    private var mocks: [RequestMock] = []

    func on(_ request: RequestMock) {
        mocks.append(request)
    }

    /**
     Initializes the mock by temporarily overwriting `URLSession.shared.dataTask`.
     */
    func initMock() {
        originalFetch = RequestUtil.shared.fetch
        originalFetch = { request in
            return try await URLSession.shared.data(for:request)
        }
        RequestUtil.shared.setFetch({ request in
            for mock in self.mocks {
                // match url and method
                guard let url = request.url, url.absoluteString == mock.url, request.httpMethod == mock.method else {
                    continue
                }

                // match body params
                if let mockBody = mock.body, let configBodyData = request.httpBody {
                    do {
                        let configBody = try JSONSerialization.jsonObject(with: configBodyData, options: []) as? [String: Any]
                        var hasMissingBodyParam = false
                        for (key, value) in mockBody {
                            if let configValue = configBody?[key], "\(configValue)" != "\(value)" {
                                hasMissingBodyParam = true
                                break
                            }
                        }
                        if hasMissingBodyParam {
                            continue
                        }
                    } catch {
                        continue
                    }
                }

                if let additionalMatcher = mock.additionalMatcher, !additionalMatcher(request) {
                    continue
                }

                let response = HTTPURLResponse(url: url, statusCode: mock.replyCode ?? 0, httpVersion: nil, headerFields: nil)!
                let data = try mock.replyBody?.data() ?? Data()
                try await Task.sleep(nanoseconds: UInt64(mock.delay ?? 0) * 1_000_000_000)
                return (data, response)
            }

            throw NSError(domain: "Request not mocked: \(request.url?.absoluteString ?? "")", code: 0)
        })
    }

    /**
     Restore the original URLSession dataTask function.
     */
    func restore() {
        RequestUtil.shared.setFetch(originalFetch)
    }

    /**
     Clears all registered mocks.
     */
    func clearMocks() {
        mocks = []
    }
}
