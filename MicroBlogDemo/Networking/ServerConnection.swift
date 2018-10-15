import Foundation

enum ServerConnectionError: Error, Equatable {
    
    case logInNotAllowedWithCurrentSession
    case logOutNotAllowedWithNoSession
    case sessionRequired
    case badJSONParse(Error)
    case unexpectedInternalError(Error)
    case emptyResponse
    case unexpectedNonHTTPURLResponse
    
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
        case (.unexpectedNonHTTPURLResponse, .unexpectedNonHTTPURLResponse):
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

        let urlSession = URLSession(configuration: sessionConfig)
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue("Bearer \(session.appToken)", forHTTPHeaderField: "Authorization")
        
        urlRequest.httpMethod = request.method.rawValue
        
        if let bodyData = request.body {
            urlRequest.httpBody = bodyData
        }
        
        if let newHeaders = request.headers {
            for h in newHeaders {
                for key in h.keys {
                    if let value = h[key] {
                        urlRequest.addValue(value, forHTTPHeaderField: key)
                    }
                }
            }
        }
        
        // FIXME: Who owns the task?
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            
            // Handle the error
            if let error = error {
                completion?(nil, ServerConnectionError.unexpectedInternalError(error))
                return
            }
            
            // Cast the response as a HTTP response
            guard let httpURLResponse = response as? HTTPURLResponse else {
                completion?(nil, ServerConnectionError.unexpectedNonHTTPURLResponse)
                return
            }
            
            // Build response, if possible
            do {
                // Debug help
                //let string = String(data: data!, encoding: .utf8)
                //print(string)
                let response = try request.responseType.init(data: data, httpURLResponse: httpURLResponse)
                completion?(response, nil)
            } catch {
                completion?(nil, ServerConnectionError.unexpectedInternalError(error))
            }
        }
        task.resume()
    }
}
