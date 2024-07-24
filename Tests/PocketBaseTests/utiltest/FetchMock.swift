import Foundation
import XCTest
@testable import PocketBase


enum ReplyBody {
    static var jsonEncoder = JSONEncoder.sorted()
    
    case json(Any)//url
    case string(String)
    func data() throws -> Data {
        switch self {
        case .json(let obj):
            return try JSONSerialization.data(withJSONObject: obj)
        case .string(let str):
            return str.data(using: .utf8)!
        }
    }
}
extension String {
    static func join(_ paths:[String]) -> String{
        let paths = paths.filter{!$0.isEmpty}.enumerated().map{
            var ele = $1
            if $0 == 0 {
                ele.removeSuffix("/")
            } else {
                ele.removePreAndSufix("/")
            }
            return ele
        }
        return paths.joined(separator: "/")
    }
    mutating func removeSuffix(_ prefix:String) {
        if self.hasSuffix(prefix) {
            self.removeLast(prefix.count)
        }
    }

    mutating func removePrefix(_ prefix:String) {
        if self.hasPrefix(prefix) {
            self.removeFirst(prefix.count)
        }
    }
    mutating func removePreAndSufix(_ prefixOrSuffix:String){
        self.removePrefix(prefixOrSuffix)
        self.removeSuffix(prefixOrSuffix)
    }
}
struct RequestMock {
    var method = HTTPMethod.GET
    var path: String?
    var body: [String: Any]?
    var additionalMatcher: ((URLRequest) -> Bool)?
    var delay: Int?
    var replyCode: Int
    var replyBody: ReplyBody?
    
    static func mock(_ method:HTTPMethod = .GET, 
                     path: String? = nil,
                     query: [String: Any]? = nil,
                     body: [String: Any]? = nil,
                     additionalMatcher:((URLRequest) -> Bool)? = nil,
                     replyCode: Int = 200,
                     replyBody: ReplyBody? = nil) -> RequestMock {
        return RequestMock(method: method, path: path, body: body,additionalMatcher: additionalMatcher, replyCode: replyCode, replyBody: replyBody)
    }
    
    func fullUrl(baseUrl:URL) -> String {
        return String.join([baseUrl.absoluteString,self.path ?? ""])
    }
}

func dummyJWT(payload: [String: Any] = [:]) -> String {
    let data = try! JSONSerialization.data(withJSONObject: payload)
    let base64String = data.base64EncodedString()
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9." + base64String + ".test"
}
func formatJSON(dict:[String:Any]) -> String? {
     return try? String(data: JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys,.prettyPrinted]), encoding: .utf8)
}

func formatJSON(data:Data) -> String? {
    guard let json = try? JSONSerialization.jsonObject(with: data) else { return nil }
    return try? String(data: JSONSerialization.data(withJSONObject: json, options: [.sortedKeys,.prettyPrinted]), encoding: .utf8)
}


class FetchMock {
    private var originalFetch: FetchCompletion?
    private var mocks: [RequestMock] = []
    
    func on(_ request: RequestMock) {
        mocks.append(request)
    }

    /**
     Initializes the mock by temporarily overwriting `URLSession.shared.dataTask`.
     */
    func initMock(baseUrl:URL) {
        originalFetch = RequestUtil.shared.fetch        
        RequestUtil.shared.setFetch({ request in
            for mock in self.mocks {
                // match url and method
                let mockUrl =  URL(string: mock.fullUrl(baseUrl: baseUrl))
                guard let url = request.url, request.httpMethod == mock.method.rawValue, url.isEqualWithQuerySorted(otherUrl: mockUrl) else {
                    print("req:\(request.httpMethod ?? "") \(request.url?.absoluteString ?? "") \nvs\nmock \(mock.method.rawValue) \(mockUrl?.absoluteString ?? "")")
                    continue
                }

                // match body params
                if let mockBody = mock.body, let requestBody = request.httpBody {
                    let a = formatJSON(dict: mockBody)
                    let b = formatJSON(data: requestBody)
                    if a != b {
                        print("req:\(a ?? "")\nmock:\(b ?? "")")
                        continue
                    }
                }

                if let additionalMatcher = mock.additionalMatcher, !additionalMatcher(request) {
                    print("matcher")
                    continue
                }

                let response = HTTPURLResponse(url: url, statusCode: mock.replyCode, httpVersion: nil, headerFields: nil)!
                let data = try mock.replyBody?.data() ?? Data()
                try await Task.sleep(nanoseconds: UInt64(mock.delay ?? 0) * 1_000_000_000)
                print("req:\(request.url?.absoluteString ?? ""),resp_len:\(data.count)")
                return (data, response)
            }
            precondition(false)
            throw NSError(domain: "Request not mocked: \(request.url?.absoluteString ?? "")", code: 0)
        })
    }

    /**
     Restore the original URLSession dataTask function.
     */
    func restore() {
        if let originalFetch {
            RequestUtil.shared.setFetch(originalFetch)
        }
    }

    /**
     Clears all registered mocks.
     */
    func clearMocks() {
        mocks = []
    }
}

protocol ServiceAWare {
    var baseService: BaseService {get}
}
class MockRequestTestCase : XCTestCase,ServiceAWare {
    var baseService: BaseService {
        let service:BaseService? = nil
        precondition(false)
        return service!
    }
    
    override class func setUp() {
        fetchMock.initMock(baseUrl: baseUrl)
    }
    
    
    override class func tearDown() {
        fetchMock.restore()
    }
    
    override func tearDownWithError() throws {
        Self.fetchMock.clearMocks()
    }
}


extension SendOptions {
    static func forTest<T:SendOptions>(q1:Any = "abc") -> T{
        T(JSON: ["query":["q1":q1],"headers":["x-test":"789"]])!
    }
}

extension MockRequestTestCase {
    func mock2(_ method:HTTPMethod = .GET,path:String = "", query:String,body:[String:Any]? = nil,replyCode:Int = 200,replyBody:ReplyBody? = nil) {
        let path = String.join([self.baseService.baseCrudPath,path])
        fetchMock.on(.mock(method,path:path+"?"+query,
                           body:body,
                           additionalMatcher: {
            $0.value(forHTTPHeaderField: "x-test") == "789"
        },
                           replyCode: replyCode,
                           replyBody:replyBody))
    }
    
    func mock(path:String = "", query:String,items:[[String:Any]]) {
        let queryParams = query.parseQueryString()
        
        let page = Int(queryParams["page"]!)!
        let perPage = Int(queryParams["perPage"]!)!
        let path = String.join([self.baseService.baseCrudPath,path])
        fetchMock.on(.mock(path:path+"?"+query,
                           additionalMatcher: {
            $0.value(forHTTPHeaderField: "x-test") == "789"
        },
                           replyCode: 200,
                           replyBody: .json([
                            "page":page,
                            "perPage":perPage,
                            "totalItems":-1,
                            "totalPages":-1,
                            "items":items
                           ])))
    }
    
    static var fetchMock: FetchMock = FetchMock()
    static let baseUrl = URL(string: "//test_base_url")!
    static var client:Client = Client(baseUrl: baseUrl)
    
    var fetchMock: FetchMock {
        return Self.fetchMock
    }
    var client: Client {
        return Self.client
    }
} 
