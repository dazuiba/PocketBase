import Foundation
/**
 * ClientResponseError is a custom Error class that is intended to wrap
 * and normalize any error thrown by `Client.send()`.
 */
struct ClientResponseError: Error {
    var name:String = "ClientResponseError"
    var message:String = "Something went wrong while processing your request."
    var request: URLRequest?
    var status: Int = 0
    var response: [String: Any] = [:]
    var isAbort: Bool = false
    var originalError: Any? = nil
    
//    init(errData: Any? = nil) {
//        if let errData = errData as? [String: Any] {
//            self.url = errData["url"] as? String ?? ""
//            self.status = errData["status"] as? Int ?? 0
//            self.isAbort = errData["isAbort"] as? Bool ?? false
//            self.originalError = errData["originalError"]
//            
//            if let response = errData["response"] as? [String: Any] {
//                self.response = response
//            } else if let data = errData["data"] as? [String: Any] {
//                self.response = data
//            } else {
//                self.response = [:]
//            }
//        }
//        
//        if self.originalError == nil && !(errData is ClientResponseError) {
//            self.originalError = errData
//        }
//        
//        self.name = "ClientResponseError \(self.status)"
//        if let msg = self.response["message"] as? String {
//            self.message = msg
//        }
//    }
    
    /**
     * Alias for `self.response` to preserve the backward compatibility.
     */
    var data: [String: Any] {
        return self.response
    }
     
}
