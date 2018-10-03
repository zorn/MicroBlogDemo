import Foundation

enum ServerConnectionError: Error {
    case logInNotAllowedWithCurrentSession
    case logOutNotAllowedWithNoSession
}

protocol ServerConnectionDelegate: class {
    func sessionDidChange(newSession: Session?)
}

class ServerConnection: NSObject {
    
    // FIXME: Not sure if configuration makes sense for testing
    let configuration: ServerConnectionConfiguration
    weak var delegate: ServerConnectionDelegate?
    private (set) var session: Session? {
        didSet {
            delegate?.sessionDidChange(newSession: session)
        }
    }
    
    init(configuration: ServerConnectionConfiguration) {
        self.configuration = configuration
        super.init()
    }
    
    func logIn() throws {
        guard session == nil else {
            throw ServerConnectionError.logInNotAllowedWithCurrentSession
        }
        session = Session()
    }
    
    func logOut() throws {
        guard session != nil else {
            throw ServerConnectionError.logOutNotAllowedWithNoSession
        }
        session = nil
    }
}
