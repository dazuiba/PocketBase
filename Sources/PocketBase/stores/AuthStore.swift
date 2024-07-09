//
//  File.swift
//  
//
//  Created by Zhanggy on 02.07.24.
//
import Foundation
import DictionaryCoder

typealias AuthModel = RecordModel //[String: Any]? // Optional dictionary

//typealias OnStoreChangeFunc = (String, AuthModel?) -> Void

let defaultCookieKey = "pb_auth"

struct AuthPayload: Codable {
    var token:String
    var model:AuthModel?
}

protocol Storage {
    associatedtype T:Codable

    func remove(forKey: String)
    func object(forKey: String) throws  -> T?
    func set(_ value: T, forKey: String) throws
}

class CachedStorage : Storage {
    typealias T = AuthPayload

    var userDefaults = UserDefaults.standard
    
    var cached: T?
    func remove(forKey: String) {
        cached = nil
        userDefaults.removeObject(forKey: forKey)
    }

    func object(forKey: String) throws -> T? {
        if let cached {
            return cached
        }
        if let value = userDefaults.object(forKey: forKey) {
            return try DictionaryDecoder().decode(T.self, from: value as! [String : Any])
        }
        return nil
    }
    
    func set(_ value: T, forKey: String) throws {
        cached = value
        let encoded = try DictionaryEncoder().encode(value)
        userDefaults.set(encoded, forKey: forKey)
    }

}

class AuthStore {
    private let storageKey: String = "pocketbase_auth"
    private var baseToken: String = ""
    private var baseModel: AuthModel? = nil
    private var storage = CachedStorage()
//    private var onChangeCallbacks: [OnStoreChangeFunc] = []

    var token: String {
        let payload = try? self.storage.object(forKey: storageKey)
        return payload?.token ?? ""
    }

    var model: AuthModel? {
        let payload = try? self.storage.object(forKey: storageKey)
        return payload?.model
    }
    
    var isValid: Bool {
        return !isTokenExpired(token)
    }
    
    var isAdmin: Bool {
        return Utils.getTokenPayload(token)["type"] as? String == "admin"
    }
    
    var isAuthRecord: Bool {
        return Utils.getTokenPayload(token)["type"] as? String == "authRecord"
    }
    
    func save(_ token: String, _ model: AuthModel? = nil){
        let payload = AuthPayload(token: token, model: model)
        try! self.storage.set(payload, forKey: storageKey)
    }

    func clear() {
        self.storage.remove(forKey: storageKey)
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
