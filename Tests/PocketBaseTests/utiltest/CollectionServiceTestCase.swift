//
//  CollectionTestCase.swift
//  
//
//  Created by Zhanggy on 21.07.24.
//

import XCTest
import ObjectMapper
@testable import PocketBase
private var service: CollectionService!
final class CollectionServiceTestCase: MockRequestTestCase {
    override var baseService: any BaseService {
        return service
    }
    override class func setUp() {
        super.setUp()
        service = CollectionService(client:client)
        service.client.authStore.clear() // reset
    }
     
    func testImport() async throws {
        mock2(.PUT,
              path: "import",
              query: "q1=456",
              body: ["collections":[["id":"id1"],["id":"id2"]],
                     "deleteMissing":true],
              replyCode: 204,
              replyBody: .string("true"))
        
        let models = Mapper<CollectionModel>().mapArray(JSONArray: [["id":"id1"],["id":"id2"]])
        let imported = try await service.doImport(models,deleteMissing: true,options: .forTest(q1: 456))
        XCTAssertTrue(imported)
    }
}
