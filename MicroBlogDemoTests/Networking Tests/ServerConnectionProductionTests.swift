import XCTest
@testable import MicroBlogDemo

/// These tests are executed against the live Micro.Blog servers, so run with care.
class ServerConnectionProductionTests: XCTestCase {

    // test_methodName_withCertainState_shouldDoSomething
    
    func test_executeRequestPostsAll_withAuthenticatedState_shouldReturnResponse() {
        
        let connection = ServerConnection(configuration: MicroBlogConfiguration())
        XCTAssertNoThrow(try connection.logIn(appToken: TestSecrets.productionAppToken))
        
        let e = XCTestExpectation(description: "connection request execution finished")
        connection.execute(RequestPostsAll()) { (response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            
            if let r = response as? ResponsePostsAll {
                XCTAssertEqual(r.jsonFeed!.items.count, 39)
            } else {
                XCTFail()
            }
            
            e.fulfill()
        }
        self.wait(for: [e], timeout: 30.0)
    }
    
    func test_executeNewPost_withValidContent_shouldReturnSuccessResponse() {
        let connection = ServerConnection(configuration: MicroBlogConfiguration())
        XCTAssertNoThrow(try connection.logIn(appToken: TestSecrets.productionAppToken))
        
        let now = JSONFeed.Formatters.dateFormatter.string(from: Date())
        let request = NewPostRequest(content: "Current date: \(now)")
        let e = XCTestExpectation(description: "connection request execution finished")
        connection.execute(request) { (response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            
            if let r = response as? NewPostResponse {
                XCTAssertEqual(r.httpURLResponse.statusCode, 202)
            } else {
                XCTFail()
            }
            
            e.fulfill()
        }
        self.wait(for: [e], timeout: 30.0)
    }
    
    func test_executeNewPost_withInvalidContent_shouldReturnErrorResponse() {
        let connection = ServerConnection(configuration: MicroBlogConfiguration())
        XCTAssertNoThrow(try connection.logIn(appToken: TestSecrets.productionAppToken))
        
        let request = NewPostRequest(content: "")
        let e = XCTestExpectation(description: "connection request execution finished")
        connection.execute(request) { (response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            
            if let r = response as? NewPostResponse {
                XCTAssertEqual(r.httpURLResponse.statusCode, 400)
                XCTAssertEqual(r.error?.error, "invalid_request")
                XCTAssertEqual(r.error?.errorDescription, "No content or photo or summary.")
            } else {
                XCTFail()
            }
            e.fulfill()
        }
        self.wait(for: [e], timeout: 30.0)
    }

}
