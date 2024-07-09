//
//  File.swift
//  
//
//  Created by Zhanggy on 06.07.24.
//

import Foundation
import Quick
import Nimble
import DictionaryCoder
@testable import PocketBase
class AuthStoreSpec:  QuickSpec{//
    override class func spec() {
        describe("AuthPayload") {
            let model = RecordModel(id: "model1")
            let payload = AuthPayload(token: "test", model: model)

            it("Dictionary encoding/decoding") {
                let encoded = try DictionaryEncoder().encode(payload)
                expect(encoded["token"] as? String).to(equal("test"))
                
                let model = try DictionaryDecoder().decode(RecordModel.self, from: encoded["model"] as! [String : Any])
                expect(model.id).to(equal("model1"))
            }
        }

        describe("AuthStore") {
            it("shoud store auth data"){
                let store = AuthStore()
                store.save("test1", AuthModel(id: "id1"))
                expect(store.token).to(equal("test1"))
                
                
                store.save("test2", AuthModel(id: "id2"))
                expect(store.token).to(equal("test2"))
                expect(store.model!.id).to(equal("id2"))
            }
            
            
            
            
            it("shoud Admin"){
                let store = AuthStore()
                expect(store.isAdmin).to(equal(false))
                store.save("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWRtaW4iLCJleHAiOjE2MjQ3ODgwMDB9.ZYNR7gqmmeu35h8Gf0uR7-jV-b21WIq8APOBLeevnuw")
                expect(store.isAdmin).to(equal(true))
            }
            
            it("shoud auth"){
                let store = AuthStore()
                expect(store.isAuthRecord).to(equal(false))
                store.save("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYXV0aFJlY29yZCIsImV4cCI6MTYyNDc4ODAwMH0.wuEMjDMF0mV_U80bjUEUfnDM6sL2n9yvy0jnU3XZUE8")
                expect(store.isAuthRecord).to(equal(true))
            }
            
            it("shoud clear auth data"){
                let store = AuthStore()
                store.save("test1", AuthModel(id: "id1"))
                expect(store.token).to(equal("test1"))
                
                store.clear()
                expect(store.token).to(equal(""))
                expect(store.model).to(beNil())
            }
        }
    }
}
