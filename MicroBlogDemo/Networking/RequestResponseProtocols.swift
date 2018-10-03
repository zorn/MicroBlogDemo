import Foundation

// MARK: - Request

enum HTTPMethod {
    case get
    case post
}

protocol RequestDescribing {
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [[String: String]]? { get }
    var body: String? { get }
}

// MARK: - Response

protocol ResponseDescribing {
    
}
