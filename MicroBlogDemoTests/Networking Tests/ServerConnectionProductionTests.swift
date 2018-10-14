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
                XCTAssertEqual(r.jsonFeed.items.count, 39)
            } else {
                XCTFail()
            }
            
            e.fulfill()
        }
        self.wait(for: [e], timeout: 30.0)
    }

}
