//
//  CrudServiceTest.swift
//  
//
//  Created by Zhanggy on 07.07.24.
//

import XCTest

import Foundation
import Quick
import Nimble
import DictionaryCoder

@testable import PocketBase
class RecordServiceSpec:  AsyncSpec{
    override class func spec() {
        describe("RecordService") {
            let baseUrl = URL(string: "//test_base_url")!
            
            let client = Client(baseUrl: baseUrl)
            let service = RecordService(client, "sub=")
            
            
            let fetchMock = FetchMock()
            beforeEach {
                service.client.authStore.clear() // reset
            }
            beforeSuite {
                fetchMock.initMock(baseUrl: baseUrl)
            }
            afterSuite {
                fetchMock.restore()
            }
            afterEach {
                fetchMock.clearMocks()
            }
            describe("AuthStore sync") {
                it("Should update the AuthStore record model on matching update id and collection") {
                    fetchMock.on(.mock(.PATCH,path: "api/collections/sub=/records/test123",replyBody: .json([
                        "id": "test123",
                        "email": "new@example.com"
                    ])))
                    
                    service.client.authStore.save("test_token",[
                        "id": "test123",
                        "collectionName": "sub="
                    ])
                    try await service.update("test123", [:])
                    let authModel = service.client.authStore.model!
                    let email = authModel["email"] as! String
                    expect(email).to(equal("new@example.com"))
                }
                
                it("Should not update the AuthStore record model on mismatched update id") {
                    fetchMock.on(.mock(.PATCH, path: "api/collections/sub%3D/records/test123", replyCode: 200, replyBody: .json([
                        "id": "test123",
                        "email": "new@example.com"
                    ])))
                    
                    service.client.authStore.save("test_token", [
                        "id": "test456",
                        "email": "old@example.com",
                        "collectionName": "sub="
                    ])
                    
                    try await service.update("test123", [:])
                    expect(service.client.authStore.model?["email"] as? String).to(equal("old@example.com"))
                }
                /**
                 
                 it("Should delete the AuthStore record model on matching delete id and collection") {
                 fetchMock.on(method: "DELETE", url: service.client.buildUrl("/api/collections/sub%3D/records/test123"), replyCode: 204)
                 service.client.authStore.save("test_token", [
                 "id": "test123",
                 "collectionName": "sub="
                 ])
                 try await service.delete("test123")
                 expect(service.client.authStore.model).to(beNil())
                 }
                 
                 it("Should not delete the AuthStore record model on matching delete id but mismatched collection") {
                 fetchMock.on(method: "DELETE", url: service.client.buildUrl("/api/collections/sub%3D/records/test123"), replyCode: 204)
                 service.client.authStore.save("test_token", [
                 "id": "test123",
                 "collectionName": "diff"
                 ])
                 try await service.delete("test123")
                 expect(service.client.authStore.model).toNot(beNil())
                 }
                 
                 it("Should not delete the AuthStore record model on mismatched delete id") {
                 fetchMock.on(method: "DELETE", url: service.client.buildUrl("/api/collections/sub%3D/records/test123"), replyCode: 204)
                 service.client.authStore.save("test_token", [
                 "id": "test456",
                 "collectionName": "sub="
                 ])
                 try await service.delete("test123")
                 expect(service.client.authStore.model).toNot(beNil())
                 }
                 
                 it("Should update the AuthStore record model verified state on matching token data") {
                 let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEyMyIsInR5cGUiOiJhdXRoUmVjb3JkIiwiY29sbGVjdGlvbklkIjoiNDU2In0.c9ZkXkC8rSqkKlpyx3kXt9ID3qYsIoy1Vz3a2m3ly0c"
                 fetchMock.on(method: "POST", url: service.client.buildUrl(service.baseCollectionPath) + "/confirm-verification", body: ["token": token], replyCode: 204, replyBody: true)
                 service.client.authStore.save("auth_token", [
                 "id": "123",
                 "collectionId": "456",
                 "verified": false
                 ])
                 let result = try await service.confirmVerification(token)
                 expect(result).to(beTrue())
                 expect(service.client.authStore.model?.verified).to(beTrue())
                 }
                 **/
                it("Should not update the AuthStore record model verified state on mismatched token data") {
                    // TODO: Add test implementation
                }
                
                it("Should delete the AuthStore record model matching the token data") {
                    // TODO: Add test implementation
                }
                
                it("Should not delete the AuthStore record model on mismatched token data") {
                    // TODO: Add test implementation
                }
            }
            
            // auth tests
            describe("listAuthMethods()") {
                it("Should fetch all available authorization methods") {
                    // TODO: Add test implementation
                }
            }
            
            describe("authWithPassword()") {
                it("(legacy) Should authenticate a record by its username/email and password") {
                    // TODO: Add test implementation
                }
                
                it("Should authenticate a record by its username/email and password") {
                    // TODO: Add test implementation
                }
            }
            
            describe("authWithOAuth2Code()") {
                it("(legacy) Should authenticate with OAuth2 a record by an OAuth2 code") {
                    // TODO: Add test implementation
                }
                
                it("Should authenticate with OAuth2 a record by an OAuth2 code") {
                    // TODO: Add test implementation
                }
            }
            
            describe("authWithOAuth2()") {
                it("(legacy) Should authenticate with OAuth2 a record using the legacy function overload") {
                    // TODO: Add test implementation
                }
                
                // TODO: consider adding a test for the realtime version when refactoring the realtime service
            }
            
            describe("authRefresh()") {
                it("(legacy) Should refresh an authorized record instance") {
                    // TODO: Add test implementation
                }
                
                it("Should refresh an authorized record instance") {
                    // TODO: Add test implementation
                }
            }
            
            describe("requestPasswordReset()") {
                it("(legacy) Should send a password reset request") {
                    // TODO: Add test implementation
                }
                
                it("Should send a password reset request") {
                    // TODO: Add test implementation
                }
            }
            
            describe("confirmPasswordReset()") {
                it("(legacy) Should confirm a password reset request") {
                    // TODO: Add test implementation
                }
                
                it("Should confirm a password reset request") {
                    // TODO: Add test implementation
                }
            }
            
            describe("requestVerification()") {
                it("(legacy) Should send a password reset request") {
                    // TODO: Add test implementation
                }
                
                it("Should send a password reset request") {
                    // TODO: Add test implementation
                }
            }
            
            describe("confirmVerification()") {
                it("(legacy) Should confirm a password reset request") {
                    // TODO: Add test implementation
                }
                
                it("Should confirm a password reset request") {
                    // TODO: Add test implementation
                }
            }
            
            describe("requestEmailChange()") {
                it("(legacy) Should send an email change request") {
                    // TODO: Add test implementation
                }
                
                it("Should send an email change request") {
                    // TODO: Add test implementation
                }
            }
            
            describe("confirmEmailChange()") {
                it("(legacy) Should confirm an email change request") {
                    // TODO: Add test implementation
                }
                
                it("Should confirm an email change request") {
                    // TODO: Add test implementation
                }
            }
            
            describe("listExternalAuths()") {
                it("Should send a list external auths request") {
                    // TODO: Add test implementation
                }
            }
            
            describe("unlinkExternalAuth()") {
                it("Should send a unlinkExternalAuth request") {
                    // TODO: Add test implementation
                }
            }
        }
    }
}
