//
//  CrudServiceTestCase.swift
//  
//
//  Created by Zhanggy on 13.07.24.
//

import XCTest

@testable import PocketBase
typealias Fixture = (CrudService<RecordModel>, String)

private var client = MockRequestTestCase.client
private var allTestFixture:[Fixture] = [
    (RecordService(client: client, "sub="),    "/api/collections/sub=/records"),
    (AdminService(client: client), "/api/admins")
]

let testItemId = "abc=".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!

final class CrudServiceTestCase: MockRequestTestCase {
    var fixgure: Fixture = allTestFixture.first!
    override var baseService: any BaseService {
        return self.service
    }
    
    var service:CrudService<RecordModel>{
        let s = self.fixgure.0
        return s
    }
    
    func testGetFullListEmptyRequestCheck() async throws {
        mock(query: "page=1&perPage=1&skipTotal=1&q1=emptyRequest", items: [["id":"item1"]])
        mock(query: "page=2&perPage=1&skipTotal=1&q1=emptyRequest", items: [["id":"item2"]])
        mock(query: "page=3&perPage=1&skipTotal=1&q1=emptyRequest", items: [])
        let result = try await service.getFullList( options: ListOptions(JSON: ["perPage":1,"query":["q1":"emptyRequest"],"headers":["x-test":"789"]]) )
        XCTAssertJSONEqual(result.toJSONExceptDefault(), [["id":"item1"],["id":"item2"]] )
    }
    
    func testGetFullListNoEmptyRequestCheck() async throws {
        mock(query: "page=1&perPage=2&skipTotal=1&q1=noEmptyRequest",items: [["id":"item1"],["id":"item2"]])
        mock(query: "page=2&perPage=2&skipTotal=1&q1=noEmptyRequest",items: [["id":"item3"]])
        
        let result = try await service.getFullList( options: ListOptions(JSON: ["perPage":2,"query":["q1":"noEmptyRequest"],"headers":["x-test":"789"]]) )
        XCTAssertJSONEqual(result.toJSONExceptDefault(), [["id":"item1"],["id":"item2"],["id":"item3"]] )
    }
     
    func testGetList() async throws {
        mock(query: "page=1&perPage=1&q1=abc",items: [["id":"item1"],["id":"item2"]])
        mock(query: "page=2&perPage=1&q1=abc",items: [["id":"item3"]])
        let list = try await service.getList(page: 2, perPage: 1, options:.forTest(q1: "abc"))
        //Should correctly return paginated list result
        XCTAssertJSONEqual(list.items.toJSONExceptDefault(), [["id":"item3"]] )
    }
    
    
    func testGetFirstListItem()  async throws {
        mock(query: "page=1&perPage=1&filter=test%3D123&skipTotal=1&q1=abc",items: [["id":"item1"]])
        let first = try await service.getFirstListItem("test=123", options: .forTest(q1: "abc"))
        XCTAssertJSONEqual(first.toJSONExceptDefault(), ["id":"item1"] )
    }
    
    func testGetOne() async throws{
        mock2(path: testItemId, query: "q1=111", replyBody: .json(["id":"item-one"]))
        let one = try await service.getOne(testItemId,options: .forTest(q1: "111"))
        XCTAssertJSONEqual(one.toJSONExceptDefault(), ["id":"item-one"] )
    }
    
    func testGetOne404IfIdEmpty() async throws{
        //assert throw
        
        await XCTAssertThrowsAsyncError(
            try await service.getOne("",options: .forTest(q1: "none"))
        ) { err in
            let error = err as? ClientResponseError
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.status,404)
        }
    }
    func testCreate()  async throws{
        mock2(.POST, query: "q1=abc", body: ["b1":123], replyBody: .json(["id":"item-create"]))
        let result = try await service.create(["b1":123], options: .forTest(q1: "abc"))
        XCTAssertJSONEqual(result.toJSONExceptDefault(), ["id":"item-create"])
    }
    
    func testUpdate()  async throws{
        mock2(.PATCH,
              path: testItemId,
              query: "q1=456", 
              body: ["avatar":123],
              replyBody: .json(["id":testItemId,"avatar":123]))
        
        let result = try await service.update(testItemId,["avatar":123], options: .forTest(q1: "456"))
        XCTAssertJSONEqual(result.toJSONExceptDefault(), ["id":testItemId,"avatar":123])
    }
    
    func testDelete() async throws{
        mock2(.DELETE, path: testItemId, query: "q1=456", body: ["b1":123],replyCode: 204)
        let deleted = try await service.delete(testItemId, options:.forTest(q1: 456))
        XCTAssertTrue(deleted)
    }
    
    func testBaseCrudPath() throws {
        print(service.baseCrudPath)
        XCTAssertEqual(service.baseCrudPath, self.fixgure.1)
    }
    
    override class var defaultTestSuite: XCTestSuite {
        let testSuite = XCTestSuite(forTestCaseClass: CrudServiceTestCase.self)

        addTestCases(to: testSuite, with: Array(allTestFixture.dropFirst()))
//
//        addTestCases(to: testSuite, for: CollectionModel.self, with: [
//            (CollectionService(client: client), "/api/collections")
//        ])
//        
        return testSuite
    }
    
    private static func addTestCases(
        to suite: XCTestSuite,
        with fixtures: [Fixture]
    ) {
        for fixture in fixtures {
            for invoke in testInvocations {
                let testCase = CrudServiceTestCase(invocation: invoke)
                testCase.fixgure = fixture
                suite.addTest(testCase)
            }
        }
    }
}
