import Foundation
struct BeforeSendResult {
    var url: String
    var options: SendOptions
}

public class Client {
    var baseUrl: URL
    var beforeSend: ((String, SendOptions) -> BeforeSendResult?)?
    var afterSend: ((Data, URLResponse) -> Any)?
    var lang = "en-US"
    public lazy var authStore: AuthStore = AuthStore()
    // var settings: SettingsService
    public lazy var admins: AdminService = AdminService(client: self)
    public lazy var collections: CollectionService = CollectionService(client: self)
    // var files: FileService
    // var logs: LogService
    // var realtime: RealtimeService
    // var health: HealthService
    // var backups: BackupService
//    var cancelControllers: [String: AbortController] = [:]
    public var recordServices: [String: Any] = [:]
//    public var enableAutoCancellation: Bool = true

    public init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }

    public func collection<M: RecordModel>(_ idOrName: String) -> RecordService<M> {
        if recordServices[idOrName] == nil {
            recordServices[idOrName] = RecordService<M>(client:self, idOrName)
        }
        return recordServices[idOrName] as! RecordService<M>
    }

/*
 public func autoCancellation(enable: Bool) -> Client {
     self.enableAutoCancellation = enable
     return self
 }
    func cancelRequest(requestKey: String) {
        if let task = cancelControllers[requestKey] {
            task.cancel()
            cancelControllers.removeValue(forKey: requestKey)
        }
    }

    func cancelAllRequests() {
        for (_, task) in cancelControllers {
            task.cancel()
        }
        cancelControllers.removeAll()
    }
    func filter(raw: String, params: [String: Any]? = nil) -> String {
        // Implement filter logic here
    }

    func getFileUrl(record: [String: Any], filename: String, queryParams: FileOptions = FileOptions()) -> String {
        // Implement getFileUrl logic here, possibly calling another service
    }
 */
    public func buildUrl(path:String) -> URL {
        self.baseUrl.appendingPathComponent(path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
    }
    
    @discardableResult
    public func send(_ path: String, _ options: SendOptions) async throws -> (Data,URLResponse) {
        
        
        var defaultHeaders = ["Content-Type":"application/json"]
        if self.authStore.isValid {
            let token = self.authStore.token
            defaultHeaders["Authorization"] = "Bearer \(token)"
        }
        
        options.headers.merge(defaultHeaders){old,new in old}
        
        let request = try options.buildRequest(forURL: self.buildUrl(path: path))
        do {
            let (data, response) = try await RequestUtil.shared.fetch(request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClientResponseError(request: request)
            }

            if httpResponse.statusCode >= 400 {
                throw ClientResponseError(request: request, status: httpResponse.statusCode)//, data: data
            }
            return (data, response)
        } catch {
            throw ClientResponseError(request: request)
        }
    } 
}
