import XCTest
import Quick
import Nimble
@testable import PBSwift

//final class PBSwiftTests: XCTestCase {
//    func testExample() throws {
//        // XCTest Documentation
//        // https://developer.apple.com/documentation/xctest
//
//        // Defining Test Cases and Test Methods
//        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
//    }
//}

class CLientSpec:  AsyncSpec{//QuickSpec
    override class func spec() {
        describe("Client") {
            
            let fetchMock = FetchMock();
            beforeSuite(){
                fetchMock.initMock()
            }
            
            afterSuite {
                fetchMock.restore()
            }
            
            afterEach {
                fetchMock.clearMocks()
            }
            
            describe("send()"){
                it("Should build and send http request") {
                    let client = Client(baseUrl: URL(string: "test_base_url")!)
                    fetchMock.on(RequestMock(url: "test_base_url", replyCode: 200, replyBody: .string("successGet")));
                    
                    /**
                     //上面是示例，请将下面的 typescript代码，按照上面的样式，转成 swift
                     fetchMock.on({
                     method: "POST",
                     url: "test_base_url/123",
                     replyCode: 200,
                     replyBody: "successPost",
                     });
                     
                     fetchMock.on({
                     method: "PUT",
                     url: "test_base_url/123",
                     replyCode: 200,
                     replyBody: "successPut",
                     });
                     
                     fetchMock.on({
                     method: "PATCH",
                     url: "test_base_url/123",
                     replyCode: 200,
                     replyBody: "successPatch",
                     });
                     
                     fetchMock.on({
                     method: "DELETE",
                     url: "test_base_url/123",
                     replyCode: 200,
                     replyBody: "successDelete",
                     });
                     
                     fetchMock.on({
                     method: "GET",
                     url: "test_base_url/multipart",
                     additionalMatcher: (_, config: any): boolean => {
                     // multipart/form-data requests shouldn't have explicitly set Content-Type
                     return !config?.headers?.["Content-Type"];
                     },
                     replyCode: 200,
                     replyBody: "successMultipart",
                     });
                     
                     fetchMock.on({
                     method: "GET",
                     url: "test_base_url/multipartAuto",
                     additionalMatcher: (_, config: any): boolean => {
                     if (
                     // multipart/form-data requests shouldn't have explicitly set Content-Type
                     config?.headers?.["Content-Type"] ||
                     // the body should have been converted to FormData
                     !(config.body instanceof FormData)
                     ) {
                     return false;
                     }
                     
                     // check FormData transformation
                     assert.deepEqual(config.body.getAll("title"), ["test"]);
                     assert.deepEqual(config.body.getAll("@jsonPayload"), [
                     '{"roles":["a","b"]}',
                     '{"json":null}',
                     ]);
                     assert.equal(config.body.getAll("files").length, 2);
                     assert.equal(config.body.getAll("files")[0].size, 2);
                     assert.equal(config.body.getAll("files")[1].size, 1);
                     
                     return true;
                     },
                     replyCode: 200,
                     replyBody: "successMultipartAuto",
                     });
                     
                     const testCases = [
                     [client.send("/123", { method: "GET" }), "successGet"],
                     [client.send("/123", { method: "POST" }), "successPost"],
                     [client.send("/123", { method: "PUT" }), "successPut"],
                     [client.send("/123", { method: "PATCH" }), "successPatch"],
                     [client.send("/123", { method: "DELETE" }), "successDelete"],
                     [
                     client.send("/multipart", { method: "GET", body: new FormData() }),
                     "successMultipart",
                     ],
                     [
                     client.send("/multipartAuto", {
                     method: "GET",
                     body: {
                     title: "test",
                     roles: ["a", "b"],
                     json: null,
                     files: [new Blob(["11"]), new Blob(["2"])],
                     },
                     }),
                     "successMultipartAuto",
                     ],
                     ];
                     for (let testCase of testCases) {
                     const responseData = await testCase[0];
                     assert.equal(responseData, testCase[1]);
                     }
                     */
                    
                    //swift code:
                    fetchMock.on(RequestMock(method: .POST, url: "test_base_url/123", replyCode: 200, replyBody: .string("successPost")));
                    fetchMock.on(RequestMock(method: .PUT, url: "test_base_url/123", replyCode: 200, replyBody: .string("successPut")));
                    fetchMock.on(RequestMock(method: .PATCH, url: "test_base_url/123", replyCode: 200, replyBody: .string("successPatch")));
                    fetchMock.on(RequestMock(method: .DELETE, url: "test_base_url/123", replyCode: 200, replyBody: .string("successDelete")));
                    
                    fetchMock.on(RequestMock(method: .GET, 
                                             url: "test_base_url/multipart",
                                             additionalMatcher: {
                                                        $0.value(forHTTPHeaderField: "Content-Type") == nil
                                                    }, 
                                             replyCode: 200,
                                             replyBody: .string("successMultipart")));
                    async let testCases = try [
                        [client.send("/123", SendOptions.option(.GET)), "successGet"],
                        [client.send("/123", .option(.POST)), "successPost"],
                        [client.send("/123", .option(.PUT)), "successPut"],
                        [client.send("/123", .option(.PATCH)), "successPatch"],
                        [client.send("/123", .option(.DELETE)), "successDelete"],
                        [client.send("/multipart", .option(.GET,body:FormData())), "successMultipart"],
//                        [client.send("/multipartAuto", .get, body: ["title": "test", "roles": ["a", "b"], "json": nil, "files": [Blob(["11"]), Blob(["2"])] ]), "successMultipartAuto"],
                    ];
//                    for testCase in testCases {
//                        let responseData = try await testCase[0];
////                        expect(responseData).to(equal(testCase[1]));
//                    }
                }
            }
        }
    }
}
