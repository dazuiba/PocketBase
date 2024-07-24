import Foundation
/**
 * ClientResponseError is a custom Error class that is intended to wrap
 * and normalize any error thrown by `Client.send()`.
 */
struct ClientResponseError: Error {
    var name:String         //= "ClientResponseError"
    var message:String      //= "Something went wrong while processing your request."
    var request: URLRequest?
    var status: Int         //     = 0
    var response: [String: Any]// = [:]
    var isAbort: Bool           //= false
    var originalError: Any?
    
    /**
     * Alias for `self.response` to preserve the backward compatibility.
     */
    var data: [String: Any] {
        return self.response
    }
    init(name: String = "ClientResponseError",
         message: String = "unknown_error",
         request: URLRequest? = nil,
         status: Int = 0,
         response: [String : Any] = [:],
         isAbort: Bool = false,
         originalError: Any? = nil) {
        precondition(false)
        self.name = name
        self.message = message
        self.request = request
        self.status = status
        self.response = response
        self.isAbort = isAbort
        self.originalError = originalError
    }
     
}
