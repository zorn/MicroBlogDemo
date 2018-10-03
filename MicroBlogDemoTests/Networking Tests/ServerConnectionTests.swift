import XCTest
@testable import MicroBlogDemo

struct TestingConfiguration: ServerConnectionConfiguration {
    let host = URL(string: "http://example.com")!
}

class ServerConnectionTests: XCTestCase {
    
    // test_methodName_withCertainState_shouldDoSomething
    
    func test_logIn_WithNoSession_shouldMakeSession() {
        let connection = ServerConnection(configuration: TestingConfiguration())
        XCTAssertNil(connection.session)
        try! connection.logIn()
        XCTAssertNotNil(connection.session)
    }
    
    func test_logIn_WithSession_shouldThrowError() {
        let connection = ServerConnection(configuration: TestingConfiguration())
        try! connection.logIn()
        XCTAssertNotNil(connection.session)
        XCTAssertThrowsError(try connection.logIn()) { error in
            XCTAssertEqual(error as! ServerConnectionError, ServerConnectionError.logInNotAllowedWithCurrentSession)
        }
    }
    
    func test_logOut_WithSession_shouldMakeSessionNil() {
        let connection = ServerConnection(configuration: TestingConfiguration())
        XCTAssertNil(connection.session)
        try! connection.logIn()
        XCTAssertNotNil(connection.session)
        try! connection.logOut()
        XCTAssertNil(connection.session)
    }
    
    func test_logOut_WithNoSession_shouldThrowError() {
        let connection = ServerConnection(configuration: TestingConfiguration())
        XCTAssertNil(connection.session)
        XCTAssertThrowsError(try connection.logOut()) { error in
            XCTAssertEqual(error as! ServerConnectionError, ServerConnectionError.logOutNotAllowedWithNoSession)
        }
    }
    
    // FIXME: Move these to their own file?
    
    func test_processRequest_withAnyState_shouldReturnRequestToken() {
        
    }
    
    func test_cancelRequest_withPreviousRequestInQueue_shouldReturnCancelRequest() {
        
    }
    
    func test_cancelRequest_withUnknownRequest_shouldReturnError() {
        
    }
}

