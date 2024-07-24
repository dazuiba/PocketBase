//
//  File.swift
//  
//
//  Created by Zhanggy on 02.07.24.
//
import Foundation
import ObjectMapper

//typealias AuthModel = RecordModel //[String: Any]? // Optional dictionary
//typealias TokenObject = RecordModel




//typealias OnStoreChangeFunc = (String, AuthModel?) -> Void

let defaultCookieKey = "pb_auth"

protocol Storage {
    associatedtype T:Mappable

    func remove()
    func object() throws  -> T?
    func set(_ value: T) throws
}

class CachedStorage : Storage {
    private let storageKey: String = "pocketbase_auth"
    typealias T = AuthPayload

    var userDefaults = UserDefaults.standard
    
    var cached: T?
    func remove() {
        cached = nil
        userDefaults.removeObject(forKey: storageKey)
    }

    func object() -> T? {
        if let cached {
            return cached
        }
        
        func readObj() -> T?{
            guard let value = userDefaults.object(forKey: storageKey) as? [String : Any]  else { return nil }
            return AuthPayload(JSON: value)
        }
        
        cached = readObj()
        return cached
    }
    
    func set(_ value: T) {
        cached = value
        let json = Mapper().toJSON(value)
        userDefaults.set(json, forKey: storageKey)
    }

}

public class AuthStore {
    private var baseToken: String = ""
    private var baseModel: AuthModel? = nil
    private var storage = CachedStorage()
//    private var onChangeCallbacks: [OnStoreChangeFunc] = []
    public var token: String {
        return self.storage.object()?.token ?? ""
    }

    public var tokenObj: TokenObject? {
        return self.storage.object()?.tokenObj
    }

    public var model: AuthModel? {
        return self.storage.object()?.model
    }
    
    public var isValid: Bool {
        return self.tokenObj?.isValid() ?? false
    }
    
    public var isAdmin: Bool {
        return self.tokenObj?.type == .admin
    }
    
    public var isAuthRecord: Bool {
        return self.tokenObj?.type == .authRecord
    }
    
    func save(_ token:String,_ dict:[String:Any]? = nil)  {
        self.save(token: token, orDict: dict)
    }
    
    func save(token: String, model: AuthModel? = nil, orDict:[String:Any]? = nil){
        var model = model
        if let orDict {
            model = AuthModel(JSON: orDict)
        }
        let payload = AuthPayload(token: token, model: model)
        self.storage.set(payload)
    }

    public func clear() {
        self.storage.remove()
    }
 
}

func cookieParse(_ cookie: String) -> [String: String] {
    // Implement cookie parsing logic here
    return [:]
}

func cookieSerialize(key: String, value: String, options: [String: Any]) -> String {
    // Implement cookie serialization logic here
    return ""
}

func isTokenExpired(_ token: String) -> Bool {
    // Implement token expiration check logic here
    return false
}

extension Dictionary {
    var jsonString: String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
