//
//  AdminService.swift
//  
//
//  Created by Zhanggy on 14.07.24.
//

import Foundation
import ObjectMapper

public class AdminService: CrudService<AdminModel> {
    public override var baseCrudPath: String {
        return "/api/admins"
    }
    
    @discardableResult
    public func authWithPassword(email: String, password: String, options: AuthOptions = AuthOptions()) async throws -> AdminAuthResponse {
        options.method = .POST
        options.body = [
            "identity": email,
            "password": password
        ]
        
        return try saveResponse(self.decode(await client.send(self.baseCrudPath + "/auth-with-password", options)))
    }
    
    public override func update(_ id: String, _ bodyParams: [String: Any]? = nil, options: CommonOptions? = nil) async throws -> AdminModel {
        let record = try await super.update(id, bodyParams, options: options)
        precondition(record.id == id)
        let authStore = self.client.authStore
        if let model = authStore.model,
           model.id == record.id,
           model.collectionId == "" {// is not record auth
            authStore.save(token: authStore.token, model: record)
        }
        return record
    }
    
    // 实现删除方法
    public override func delete(_ id: String, options: CommonOptions? = nil) async throws -> Bool {
        let success = try await super.delete(id, options: options)
        // 清除存储状态
        let authStore = self.client.authStore
        if success && authStore.model?.id == id && authStore.model?.collectionId == nil {
            authStore.clear()
        }
        return success
    }
    
    // 处理认证响应
    public func saveResponse(_ response: AdminAuthResponse) throws -> AdminAuthResponse {
        let admin = response.admin
        let token = response.token
        if !token.isEmpty {
            let authStore = self.client.authStore
            authStore.save(token: token, model: admin)
        }
        return response
    }
    
}



public struct AdminAuthResponse: Mappable {
    public init?(map: ObjectMapper.Map) {
        
    }
    
    mutating public func mapping(map: ObjectMapper.Map) {
        token <- map["token"]
        admin <- map["admin"]
    }
    
    public var token: String = ""
    public var admin: AdminModel?
}
