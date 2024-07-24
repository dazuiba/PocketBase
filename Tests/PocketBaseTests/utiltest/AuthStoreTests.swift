import XCTest
@testable import PocketBase

class AuthStoreTests: XCTestCase {
    func testAuthPayloadDictionaryEncodingDecoding() throws {
        let model = try XCTUnwrap(RecordModel(JSON: ["id": "model1"]))
        let payload = try XCTUnwrap(AuthPayload(JSON: ["token":"test","model":model.toJSON()]))

        let encoded = payload.toJSON()
        XCTAssertEqual(encoded["token"] as? String, "test")
        XCTAssertEqual(model.id, "model1")
    }

    func testAuthStoreShouldStoreAuthData() throws {
        let store = AuthStore()
        store.save("test1", ["id":"id1"])
        XCTAssertEqual(store.token, "test1")

        store.save("test2", ["id":"id2"])
        XCTAssertEqual(store.token, "test2")
        XCTAssertEqual(store.model!.id, "id2")
    }

    func testAuthStoreShouldAdmin() throws {
        let store = AuthStore()
        XCTAssertFalse(store.isAdmin)
        store.save("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWRtaW4iLCJleHAiOjE2MjQ3ODgwMDB9.ZYNR7gqmmeu35h8Gf0uR7-jV-b21WIq8APOBLeevnuw")
        XCTAssertTrue(store.isAdmin)
    }

    func testAuthStoreShouldAuth() throws {
        let store = AuthStore()
        XCTAssertFalse(store.isAuthRecord)
        store.save("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYXV0aFJlY29yZCIsImV4cCI6MTYyNDc4ODAwMH0.wuEMjDMF0mV_U80bjUEUfnDM6sL2n9yvy0jnU3XZUE8")
        XCTAssertTrue(store.isAuthRecord)
    }

    func testAuthStoreShouldClearAuthData() throws {
        let store = AuthStore()
        store.save("test1", ["id":"id1"])
        XCTAssertEqual(store.token, "test1")

        store.clear()
        XCTAssertEqual(store.token, "")
        XCTAssertNil(store.model)
    }
}
