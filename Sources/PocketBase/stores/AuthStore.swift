//
//  File.swift
//  
//
//  Created by Zhanggy on 02.07.24.
//
import Foundation

typealias AuthModel = [String: Any]? // Optional dictionary

//typealias OnStoreChangeFunc = (String, AuthModel?) -> Void

let defaultCookieKey = "pb_auth"

class AuthStore {
    private let storageKey: String = "pocketbase_auth"
    private var baseToken: String = ""
    private var baseModel: AuthModel? = nil
    private var userDefaults = UserDefaults.standard
//    private var onChangeCallbacks: [OnStoreChangeFunc] = []

    var token: String {
        let data = storageGet(storageKey) as? [String: Any] ?? [:]
        return data["token"] as? String ?? ""
    }

    var model: AuthModel? {
        let data = storageGet(storageKey) as? [String: Any] ?? [:]
        return data["model"] as? AuthModel
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
    
    func save(_ token: String, _ model: AuthModel? = nil) {
        
        var dict = ["token": token as Any]
        if let model {
            dict["model"] = model
        }
        
        storageSet(storageKey, value:dict)
    }

    func clear() {
        storageRemove(storageKey)
    }

    // Internal helpers:

    private func storageGet(_ key: String) -> Any? {
        self.userDefaults.object(forKey: key)
    }

    private func storageSet(_ key: String, value: Any) {
        self.userDefaults.set(value, forKey: key)
    }

    private func storageRemove(_ key: String) {
        self.userDefaults.removeObject(forKey: key)
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
