// Convert the following TypeScript code to Swift:
/*
export interface SendOptions extends RequestInit {
    // for backward compatibility and to minimize the verbosity,
    // any top-level field that doesn't exist in RequestInit or the
    // fields below will be treated as query parameter.
    [key: string]: any;

    /**
     * Optional custom fetch function to use for sending the request.
     */
    fetch?: (url: RequestInfo | URL, config?: RequestInit) => Promise<Response>;

    /**
     * Custom headers to send with the requests.
     */
    headers?: { [key: string]: string };

    /**
     * The body of the request (serialized automatically for json requests).
     */
    body?: any;

    /**
     * Query parameters that will be appended to the request url.
     */
    query?: { [key: string]: any };

    /**
     * @deprecated use `query` instead
     *
     * for backward-compatibility `params` values are merged with `query`,
     * but this option may get removed in the final v1 release
     */
    params?: { [key: string]: any };

    /**
     * The request identifier that can be used to cancel pending requests.
     */
    requestKey?: string | null;

    /**
     * @deprecated use `requestKey:string` instead
     */
    $cancelKey?: string;

    /**
     * @deprecated use `requestKey:null` instead
     */
    $autoCancel?: boolean;
}

export interface CommonOptions extends SendOptions {
    fields?: string;
}

export interface ListOptions extends CommonOptions {
    page?: number;
    perPage?: number;
    sort?: string;
    filter?: string;
    skipTotal?: boolean;
}

export interface FullListOptions extends ListOptions {
    batch?: number;
}

export interface RecordOptions extends CommonOptions {
    expand?: string;
}

export interface RecordListOptions extends ListOptions, RecordOptions {}

export interface RecordFullListOptions extends FullListOptions, RecordOptions {}

export interface LogStatsOptions extends CommonOptions {
    filter?: string;
}

export interface FileOptions extends CommonOptions {
    thumb?: string;
    download?: boolean;
}

export interface AuthOptions extends CommonOptions {
    /**
     * If autoRefreshThreshold is set it will take care to auto refresh
     * when necessary the auth data before each request to ensure that
     * the auth state is always valid.
     *
     * The value must be in seconds, aka. the amount of seconds
     * that will be subtracted from the current token `exp` claim in order
     * to determine whether it is going to expire within the specified time threshold.
     *
     * For example, if you want to auto refresh the token if it is
     * going to expire in the next 30mins (or already has expired),
     * it can be set to `1800`
     */
    autoRefreshThreshold?: number;
}

// -------------------------------------------------------------------

// list of known SendOptions keys (everything else is treated as query param)
const knownSendOptionsKeys = [
    "requestKey",
    "$cancelKey",
    "$autoCancel",
    "fetch",
    "headers",
    "body",
    "query",
    "params",
    // ---,
    "cache",
    "credentials",
    "headers",
    "integrity",
    "keepalive",
    "method",
    "mode",
    "redirect",
    "referrer",
    "referrerPolicy",
    "signal",
    "window",
];

// modifies in place the provided options by moving unknown send options as query parameters.
export function normalizeUnknownQueryParams(options?: SendOptions): void {
    if (!options) {
        return;
    }

    options.query = options.query || {};
    for (let key in options) {
        if (knownSendOptionsKeys.includes(key)) {
            continue;
        }

        options.query[key] = options[key];
        delete options[key];
    }
}

*/

// Swift code:
import Foundation

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

enum HeaderKey : String {
    case Content_Type = "Content-Type"
}

enum HeaderValue: String {
    case Application_json = "application/json"
}

typealias Headers =  [HeaderKey: HeaderValue]

extension URLComponents {
    mutating func appendQueryItems(_ items:[URLQueryItem]) {
        if let origin = self.queryItems {
            self.queryItems = origin + items
        } else {
            self.queryItems = items
        }
    }
}
public struct FormData {
    
    func asData() -> Data {
        return Data()
    }
    
}
extension URLRequest {
    mutating func process(body:Any,headers:Headers) throws {
        switch body {
        case let body as Data:
            self.httpBody = body
        case let body as String:
            let appJson = headers[HeaderKey.Content_Type] == .Application_json
            self.httpBody = appJson ? try JSONSerialization.data(withJSONObject: body) : body.data(using: .utf8)
        case let body as FormData:
            self.httpBody = body.asData()
        case let body as Encodable:
            self.httpBody = try JSONEncoder.normal().encode(body)
        default:
            self.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
    }
}

protocol SendOptionsProtocol {
    associatedtype QueryType

    var method: HTTPMethod { get set }
    var headers: [HeaderKey: HeaderValue] { get set }
    var body: Any? { get set }
    var query: QueryType? { get set } 
}

class SendOptions: SendOptionsProtocol {
    typealias QueryType = [String: Any]
    
    var method = HTTPMethod.GET
    var headers = Headers()
    var body: Any?
    var query: [String: Any]?
    var requestKey: String?
    
    public static func option(_ method:HTTPMethod = .GET, body:Any? = nil) -> SendOptions {
        let option = SendOptions()
        option.method = method
        option.body = body
        return option
    }

    func buildRequest(forURL:URL) throws -> URLRequest {
        // Serialize the query parameters
        var comp = URLComponents(url: forURL, resolvingAgainstBaseURL: true)
        if let query = self.query {
            comp?.appendQueryItems(query.map {  URLQueryItem(name: $0, value:"\($1)")} )
        }
        
        guard let url = comp?.url else {
            throw PocketBaseError.invalidArgument("url:\(forURL),query:\(String(describing: self.query))")
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        request.allHTTPHeaderFields = self.headers.reduce(into: [String: String]()) {
            $0[$1.key.rawValue] = $1.value.rawValue
        }
        if let body = self.body{
            try request.process(body: body, headers: self.headers)
        }
        return request
    }
}

class CommonOptions: SendOptions {
    var fields: String?
}

class ListOptions: CommonOptions {
    var page: Int?
    var perPage: Int?
    var sort: String?
    var filter: String?
    var skipTotal: Bool?
}
class FullListOptions: ListOptions {
    var batch: Int?
}

class RecordOptions: CommonOptions {
    var expand: String?
}

class FileOptions: CommonOptions {
    var thumb: String?
    var download: Bool?
}
// class RecordListOptions: ListOptions, RecordOptions {

// }

typealias OAuth2UrlCallback = (String) -> Void

class OAuth2AuthConfig: SendOptionsProtocol {
    
    var method = HTTPMethod.GET
    var headers = [HeaderKey: HeaderValue]()
    var body: Any?

    var provider: String!
    var scopes: [String]?
    var createData: [String: Any]?
    var urlCallback: OAuth2UrlCallback?
    
    typealias QueryType = RecordOptions
    var query: RecordOptions?
}
