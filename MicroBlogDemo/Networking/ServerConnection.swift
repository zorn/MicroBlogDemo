import Foundation

enum ServerConnectionError: Error, Equatable {
    
    case logInNotAllowedWithCurrentSession
    case logOutNotAllowedWithNoSession
    case sessionRequired
    case badJSONParse(Error)
    case unexpectedInternalError(Error)
    case emptyResponse
    
    static func == (lhs: ServerConnectionError, rhs: ServerConnectionError) -> Bool {
        switch (lhs, rhs) {
        case let (.badJSONParse(a), .badJSONParse(b)):
            return areEqual(a, b)
        case let (.unexpectedInternalError(a), .unexpectedInternalError(b)):
            return areEqual(a, b)
        case (.logInNotAllowedWithCurrentSession, .logInNotAllowedWithCurrentSession):
            return true
        case (.logOutNotAllowedWithNoSession, .logOutNotAllowedWithNoSession):
            return true
        case (.sessionRequired, .sessionRequired):
            return true
        case (.emptyResponse, .emptyResponse):
            return true
        default:
            return false
        }
    }
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
    
    func logIn(appToken: String) throws {
        guard session == nil else {
            throw ServerConnectionError.logInNotAllowedWithCurrentSession
        }
        session = Session(appToken: appToken)
    }
    
    func logOut() throws {
        guard session != nil else {
            throw ServerConnectionError.logOutNotAllowedWithNoSession
        }
        session = nil
    }
    
    func execute(_ request: RequestDescribing, completion: ((ResponseDescribing?, Error?) -> Void)?) {
        
        guard let session = session else {
            completion?(nil, ServerConnectionError.sessionRequired)
            return
        }
        
        let url = configuration.host.appendingPathComponent(request.path)

        let sessionConfig = URLSessionConfiguration.default
        //sessionConfig.httpAdditionalHeaders = ["Authorization": "Bearer \(session.appToken)"]
        let urlSession = URLSession(configuration: sessionConfig)
        // FIXME: Who owns the task?
        var request = URLRequest(url: url)
        request.addValue("Bearer \(session.appToken)", forHTTPHeaderField: "Authorization")
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            
            // FIXME: How do I make this a guard?
            if let error = error {
                // FIXME: Not sure if I should bother wrapping these? Feel like I should account for all
                // errors I return and in this case, there is nothing I can do.
                completion?(nil, ServerConnectionError.unexpectedInternalError(error))
                return
            }
            
            guard let data = data else {
                completion?(nil, ServerConnectionError.emptyResponse)
                return
            }
            
            // FIXME: Does the HTTPResponse belong in the Response object?
            do {
                let jsonFeed = try JSONFeed.Tools.standardDecoder.decode(JSONFeed.self, from: data)
                completion?(ResponsePostsAll(jsonFeed: jsonFeed), nil)
            } catch {
                completion?(nil, ServerConnectionError.badJSONParse(error))
            }
        }
        task.resume()
    }
}
