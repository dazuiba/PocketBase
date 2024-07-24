import XCTest

@testable import PocketBase

class ClientTests: MockRequestTestCase {
 

    func testSendHttpRequest() async throws {
        fetchMock.on(.mock(path: "123", replyCode: 200, replyBody: .string("successGet")))
        fetchMock.on(.mock(.POST, path: "123", replyCode: 200, replyBody: .string("successPost")))
        fetchMock.on(.mock(.PUT, path: "123", replyCode: 200, replyBody: .string("successPut")))
        fetchMock.on(.mock(.PATCH, path: "123", replyCode: 200, replyBody: .string("successPatch")))
        fetchMock.on(.mock(.DELETE, path: "123", replyCode: 200, replyBody: .string("successDelete")))
        fetchMock.on(.mock(path: "multipart", additionalMatcher: {
            $0.value(forHTTPHeaderField: "Content-Type") == nil
        }, replyCode: 200, replyBody: .string("successMultipart")))
        
        let testCases = try await [
            [client.send("/123", .option()), "successGet"],
            [client.send("/123", .option(.POST)), "successPost"],
            [client.send("/123", .option(.PUT)), "successPut"],
            [client.send("/123", .option(.PATCH)), "successPatch"],
            [client.send("/123", .option(.DELETE)), "successDelete"],
//            [client.send("/multipart", .option(.GET,body:FormData())), "successMultipart"],
        ];
        
        for testCase in testCases {
            let (data,_) = testCase[0] as! (Data,URLResponse)
            
            let dataStr = String(data: data, encoding: .utf8)
            
            XCTAssertEqual(dataStr, testCase[1] as? String)
        }
    }
}
