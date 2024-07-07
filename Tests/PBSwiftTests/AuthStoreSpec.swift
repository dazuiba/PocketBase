//
//  File.swift
//  
//
//  Created by Zhanggy on 06.07.24.
//

import Foundation
import Quick
import Nimble
@testable import PocketBase
class AuthStoreSpec:  QuickSpec{//
    override class func spec() {
        describe("AuthStore") {
            it("shoud store auth data"){
                let store = AuthStore()
                store.save("test1", ["id":"id1"])
                expect(store.token).to(equal("test1"))
                
                
                store.save("test2", ["id":"id2"])
                expect(store.token).to(equal("test2"))
                expect(store.model! as? [String:String]).to(equal(["id":"id2"]))
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
                store.save("test1", ["id":"id1"])
                expect(store.token).to(equal("test1"))
                
                store.clear()
                expect(store.token).to(equal(""))
                expect(store.model).to(beNil())
            }
        }
    }
}
