//
//  AdminServiceTestCase.swift
//  
//
//  Created by Zhanggy on 21.07.24.
//

import XCTest
@testable import PocketBase
fileprivate var service: AdminService!
fileprivate let token = dummyJWT(payload: ["id":"test_id","type":"admin","exp":(Date().timeIntervalSince1970 - 1 * 60000).rounded(.down)])

public func loginPairFromEnv() throws -> (String,String) {
    let pair = try XCTUnwrap(ProcessInfo.processInfo.environment["TestAdminPair"])
    let splits = pair.split(separator: ":")
    guard splits.count == 2 else {
        throw PocketBaseError.invalidArgument("invalid environment")
    }
    return (String(splits[0]),String(splits[1]))
}

final class AdminServiceTestCase: MockRequestTestCase {
    override class func setUp() {
        super.setUp()
        service = AdminService(client: client)
    }
    override var baseService: any BaseService {
        return service
    }
    
    func testLogin() async throws {
        let (login,passwd) = try loginPairFromEnv()

        mock2(.POST,path:"auth-with-password",
              query: "q1=1",
              body: ["identity":login,"password":passwd],
              replyBody: .json(["token":token,"admin":["id":"test_id"]])
        )

        
        let result = try await service.authWithPassword(email:login, password:passwd,options: .forTest(q1: "1"))
        try authResponseCheck(result: result, expectedToken: token, expectedAdmin: ["id":"test_id"])
    }
    
    func authResponseCheck(result: AdminAuthResponse, expectedToken: String, expectedAdmin: [String:Any]) throws{
        XCTAssertEqual(result.token, expectedToken)
        XCTAssertJSONEqual(result.admin?.toJSONExceptDefault() ?? [:], expectedAdmin)
        XCTAssertEqual(service.client.authStore.token, expectedToken)
        let model = try XCTUnwrap(service.client.authStore.model)
        
        XCTAssertJSONEqual(model.toJSONExceptDefault(), expectedAdmin)
    }

}
