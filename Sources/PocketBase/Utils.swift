import Foundation
public typealias FetchCompletion = (URLRequest) async throws -> (Data, URLResponse)

enum PocketBaseError: Error {
  case invalidArgument(String)
}


extension JSONEncoder {
    static func normal() -> JSONEncoder {
        let encoder = JSONEncoder()
        return encoder
    }
    
    static func sorted() -> JSONEncoder {
        let encoder = normal()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }
}

public class RequestUtil {
    public private(set) var fetch: FetchCompletion = {request in try await URLSession.shared.data(for:request)}
    
    public func setFetch(_ fetch: @escaping FetchCompletion) {
        self.fetch = fetch
    }
    
    public static var shared = RequestUtil()
}

public class Utils {
    static func isTokenExpired(_ token: String) -> Bool {
        let payload = getTokenPayload(token)
        if let exp = payload["exp"] as? Double {
            return Date().timeIntervalSince1970 >= exp
        }
        return true
    }
    
    static func getTokenPayload(_ token: String) -> [String: Any] {
        let parts = token.components(separatedBy: ".")
        if parts.count == 3 {
            if let payloadData = paddedAndDecodeBase64(parts[1]) {
                if let payload = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any] {
                    return payload 
                }
            }
        }
        return [:]
    } 
    

    public static func paddedAndDecodeBase64(_ base64String: String) -> Data? {
        // 计算需要填充的 `=` 数量
        let remainder = base64String.count % 4
        let paddingCount = remainder > 0 ? 4 - remainder : 0
        
        // 使用 `=` 填充字符串
        let string = base64String.padding(toLength: base64String.count + paddingCount, withPad: "=", startingAt: 0)
        return Data(base64Encoded: string, options: .ignoreUnknownCharacters)
    }
}
