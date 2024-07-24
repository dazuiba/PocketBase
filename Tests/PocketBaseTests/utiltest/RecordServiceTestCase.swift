//
//  RecordServiceTestCase.swift
//  
//
//  Created by Zhanggy on 12.07.24.
//
import XCTest

@testable import PocketBase

private var service: RecordService<RecordModel>!
//var fetchMock: FetchMock!
//let baseUrl = URL(string: "//test_base_url")!

class RecordServiceTest: MockRequestTestCase {
    
    override class func setUp() {
        super.setUp()
        service = RecordService(client:client, "sub=")
        service.client.authStore.clear() // reset
    }
     

    func testAuthStoreSyncOnMatchingUpdateIdAndCollection() async throws {
        fetchMock.on(.mock(.PATCH, path: "api/collections/sub=/records/test123", replyBody: .json([
            "id": "test123",
            "email": "new@example.com"
        ])))

        service.client.authStore.save("test_token", [
            "id": "test123",
            "collectionName": "sub="
        ])
        try await service.update("test123", [:])
        let authModel = service.client.authStore.model!

        XCTAssertEqual(authModel.email, "new@example.com")
    }

    func testAuthStoreSyncOnMismatchedUpdateId() async throws {
        fetchMock.on(.mock(.PATCH, path: "api/collections/sub=/records/test123", replyCode: 200, replyBody: .json([
            "id": "test123",
            "email": "new@example.com"
        ])))

        service.client.authStore.save("test_token", [
            "id": "test456",
            "email": "old@example.com",
            "collectionName": "sub="
        ])

        try await service.update("test123", [:])
        XCTAssertEqual(service.client.authStore.model?.email as? String, "old@example.com")
    }

    func testAuthStoreSyncOnMatchingDeleteIdAndCollection() async throws {
        fetchMock.on(.mock(.DELETE, path: "api/collections/sub=/records/test123", replyCode: 204))

        service.client.authStore.save("test_token", [
            "id": "test123",
            "collectionName": "sub="
        ])
        try await service.delete("test123")
        XCTAssertNil(service.client.authStore.model)
    }

    func testAuthStoreSyncOnMatchingDeleteIdButMismatchedCollection() async throws {
        fetchMock.on(.mock(.DELETE, path: "api/collections/sub=/records/test123", replyCode: 204))
        service.client.authStore.save("test_token", [
            "id": "test123",
            "collectionName": "diff"
        ])
        try await service.delete("test123")
        XCTAssertNotNil(service.client.authStore.model)
    }

    func testAuthStoreSyncOnMismatchedDeleteId() async throws {
        fetchMock.on(.mock(.DELETE, path: "api/collections/sub=/records/test123", replyCode: 204))
        service.client.authStore.save("test_token", [
            "id": "test456",
            "collectionName": "sub="
        ])
        try await service.delete("test123")
        XCTAssertNotNil(service.client.authStore.model)
    }

    func testAuthStoreRecordModelVerifiedStateOnMatchingTokenData() async throws {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEyMyIsInR5cGUiOiJhdXRoUmVjb3JkIiwiY29sbGVjdGlvbklkIjoiNDU2In0.c9ZkXkC8rSqkKlpyx3kXt9ID3qYsIoy1Vz3a2m3ly0c"

        fetchMock.on(.mock(.POST, path: "api/collections/sub=/confirm-verification", body: ["token": token], replyCode: 204, replyBody: .string("true")))
        service.client.authStore.save("auth_token", [
            "id": "123",
            "collectionId": "456",
            "verified": false
        ])

        try await service.confirmVerification(token)
        XCTAssertTrue(service.client.authStore.model?.verified ?? false)
    }
}
