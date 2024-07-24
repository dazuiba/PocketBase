import Foundation
import ObjectMapper

public typealias FetchCompletion = (URLRequest) async throws -> (Data, URLResponse)

enum PocketBaseError: Error {
  case invalidArgument(String)
  case invalidResponse(Any)
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
    public private(set) var fetch: FetchCompletion = {request in
        try await RequestUtil.shared.innerDoFetch(request)
    }
    
    public func setFetch(_ fetch: @escaping FetchCompletion) {
        self.fetch = fetch
    }
    
    public static var shared = RequestUtil()
    public lazy var fetchSession = URLSession.shared

    public func innerDoFetch(_ request:URLRequest) async throws -> (Data, URLResponse) {
        print("\(request.httpMethod ?? "nil"): \(request.url?.absoluteString ?? "")\n\t header:\(request.allHTTPHeaderFields ?? [:])\n\t body:\(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
        
        return try await fetchSession.data(for:request)
    }
    init() {
        /*
        let useProxy = false
        if (useProxy){
            let proxy = "0.0.0.0:9090"
            print("use http_proxy: ")
            let configuration = URLSessionConfiguration.default
            // 设置 HTTP 代理
            configuration.connectionProxyDictionary = [
                kCFNetworkProxiesHTTPEnable as String: true,
                kCFNetworkProxiesHTTPProxy as String: proxy.split(separator:":")[0],
                kCFNetworkProxiesHTTPPort as String: proxy.split(separator:":")[1] 
            ]
            print(configuration)
            fetchSession = URLSession(configuration: configuration)
        }
         */
    }
}



public class Utils {
    /*
    @propertyWrapper
    struct Expandable<T> {
        private var key: String
        private var expand: [String: Any]

        var wrappedValue: T? {
            get {
                return expand[key] as? T
            }
            set {
                updateValue(newValue)
            }
        }

        init(key: String, expand: [String: Any]) {
            self.key = key
            self.expand = expand
        }

        private mutating func updateValue(_ value: T?) {
            expand[key] = value
        }
    }

    */
    static func tryDo<T>(_ block: () throws -> T) -> T? {
        do {
            return try block()
        } catch {
            print("error:",error)
            return nil
        }
    }
    
    static func getTokenPayload(_ token: String) -> TokenObject? {
        let parts = token.components(separatedBy: ".")
        if parts.count == 3 {
            if let payloadData = paddedAndDecodeBase64(parts[1]) {
                return TokenObject(JSONData: payloadData)
            }
        }
        return nil
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
extension String {
    func parseQueryString() -> [String: String] {
        var result = [String: String]()
        let pairs = self.components(separatedBy: "&")
        for pair in pairs {
            let keyValue = pair.components(separatedBy: "=")
            if keyValue.count == 2 {
                result[keyValue[0]] = keyValue[1]
            }
        }
        return result
    }
}
extension BaseMappable {
    
    init?(JSONData data: Data, context: MapContext? = nil) {
        guard let JSON = Utils.tryDo({ try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) }) as? [String:Any] else { return nil
        }
        
        if let obj: Self = Mapper(context: context).map(JSON: JSON) {
            self = obj
        } else {
            return nil
        }
    }
    
    public func toJSONExceptDefault() -> [String : Any] {
        var result = self.toJSON()
        result.cleanDefaultValue()
        return result
    }
    
}

public extension Dictionary where Key == String {
    fileprivate mutating func cleanDefaultValue(){
        let emptyKeys = self.keys.filter{
            let value = self[$0]
            switch value {
            case let v as Int:
                return v <= 0
            case let v as String:
                return v.isEmpty
            case let v as Array<Any>:
                return v.isEmpty
            case let v as Dictionary:
                return v.isEmpty
            case let v as Bool:
                return v == false
            case let v as Data:
                return v.isEmpty
            default:
                precondition(false)
                return false
            }
        }
        //remove keys in emptyKeys
        emptyKeys.forEach{
            self.removeValue(forKey: $0)
        }
    }
}

public extension Array where Element: BaseMappable {
    init?(JSONData data: Data, context: MapContext? = nil) {
        
        guard let json = Utils.tryDo({ try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) }) as? [[String:Any]] else { return nil
        }
        self = Mapper<Element>(context: context).mapArray(JSONArray: json)
    }
    
    func toJSONExceptDefault() -> [[String : Any]] {
        self.map{$0.toJSONExceptDefault()}
    }
}


public extension Dictionary where Key == String {
    func toQueryString(sorted: Bool = false) -> String {
        self.map{URLQueryItem(name: $0, value: String(describing: $1))}.toQueryString()
    } 
}
extension Array where Element == URLQueryItem {
    func toQueryString(sorted: Bool = false) -> String {
        let items = sorted ? self.sorted { $0.name < $1.name } : self
        return items.map { queryItem in
            let name = queryItem.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let value = queryItem.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(name)=\(value)"
        }
        .joined(separator: "&")
    }
}
extension URL {
    func isEqualWithQuerySorted(otherUrl:URL?) -> Bool {
        if let otherUrl,
            let a = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let b = URLComponents(url: otherUrl, resolvingAgainstBaseURL: false) {
            return a.isEqualWithQuerySorted(otherUrl: b)
        }
        return false
    }
}
extension URLComponents {
    func isEqualWithQuerySorted(otherUrl:URLComponents) -> Bool {
        if self.urlWithoutQuery == otherUrl.urlWithoutQuery {
            let a = self.queryItems?.toQueryString(sorted: true) ?? ""
            let b = otherUrl.queryItems?.toQueryString(sorted: true) ?? ""
            if a == b {
                return true
            } else {
                print("\(a) vs \(b)")
                return false
            }
        }
        return false
    }
    
    var urlWithoutQuery: URLComponents? {
        var compo = URLComponents(string: self.url?.absoluteString ?? "")
        compo?.query = nil
        return compo
    }
}

extension DateFormatterTransform {
    static let defaultPocketBase = DateFormatterTransform(dateFormatter: .defaultPocketBase)
}

public extension DateFormatter {
  /// Default date formatting used by PocketBase server.
  static let defaultPocketBase: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSX"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .init(secondsFromGMT: 0)
    formatter.calendar = Calendar(identifier: .iso8601)
    return formatter
  }()
}
