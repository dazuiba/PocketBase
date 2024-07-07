import Foundation
import Quick
import Nimble
@testable import PocketBase

class ClientSpec:  AsyncSpec{//QuickSpec
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
                    fetchMock.on(.mock(url: "test_base_url/123", replyCode: 200, replyBody: .string("successGet")));
                    //swift code:
                    fetchMock.on(.mock(.POST, url: "test_base_url/123", replyCode: 200, replyBody: .string("successPost")));
                    fetchMock.on(.mock(.PUT, url: "test_base_url/123", replyCode: 200, replyBody: .string("successPut")));
                    fetchMock.on(.mock(.PATCH, url: "test_base_url/123", replyCode: 200, replyBody: .string("successPatch")));
                    fetchMock.on(.mock(.DELETE, url: "test_base_url/123", replyCode: 200, replyBody: .string("successDelete")));
                    fetchMock.on(.mock(url: "test_base_url/multipart",
                                       additionalMatcher: {
                        $0.value(forHTTPHeaderField: "Content-Type") == nil
                    },
                                       replyCode: 200,
                                       replyBody: .string("successMultipart")));
                    
                    let testCases = try await [
                        [client.send("/123", .option()), "successGet"],
                        [client.send("/123", .option(.POST)), "successPost"],
                        [client.send("/123", .option(.PUT)), "successPut"],
                        [client.send("/123", .option(.PATCH)), "successPatch"],
                        [client.send("/123", .option(.DELETE)), "successDelete"],
                        [client.send("/multipart", .option(.GET,body:FormData())), "successMultipart"],
                    ];
                   for testCase in testCases {
                       let (data,_) = testCase[0] as! (Data,URLResponse)
                       
                       let dataStr = String(data: data, encoding: .utf8)
                       
                       expect(dataStr).to(equal(testCase[1] as! String));
                   }
                }
            }
        }
    }
}
