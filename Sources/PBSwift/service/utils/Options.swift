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

struct Response {
    
}

struct RequestInfo {
    
}
protocol RequestInit {

}
enum HTTPMethod: String {
  case GET = "GET"
  case POST = "POST"
  case PATCH = "PATCH"
  case DELETE = "DELETE"
}

enum HeaderKey : String {
    case Content_Type = "Content-Type"
}

enum HeaderValue: String {
    case Application_json = "application/json"
}



extension URLComponents {
    mutating func appendQueryItems(_ items:[URLQueryItem]) {
        if let origin = self.queryItems {
            self.queryItems = origin + items
        } else {
            self.queryItems = items
        }
    }
}
extension URLRequest {
    mutating func processBody(_ body:Any,encoder:JSONEncoder,accpetJSON:Bool) throws {
        if let body = body as? Data {
            self.httpBody = body
            return
        }
        if let body = body as? String {
            if accpetJSON {
                self.httpBody = try JSONSerialization.data(withJSONObject: body)
            } else {
                self.httpBody = body.data(using: .utf8)
            }
            return
        }
        
        precondition(accpetJSON)
        if let body = body as? Encodable {
            self.httpBody = try encoder.encode(body)
        } else {
            precondition( false )//should not reach here
        }
    }
}
class SendOptions: RequestInit {
    
    var jsonEncoder = JSONEncoder.normal()
    
    var method = HTTPMethod.GET

    /**
     * Custom headers to send with the requests.
     */
    var headers = [HeaderKey: HeaderValue]()

    /**
     * The body of the request (serialized automatically for json requests).
     */
    var body: Any?

    /**
     * Query parameters that will be appended to the request url.
     */
    var query: [String: Any]?

    /**
     * The request identifier that can be used to cancel pending requests.
     */
    var requestKey: String?

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
            try request.processBody(body,
                                    encoder: self.jsonEncoder,
                                    accpetJSON: self.headers[HeaderKey.Content_Type] == .Application_json)
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
