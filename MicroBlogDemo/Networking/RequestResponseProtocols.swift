import Foundation

// MARK: - Request

enum HTTPMethod: String {
    case get
    case post
}

protocol RequestDescribing {
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [[String: String]]? { get }
    var body: Data? { get }
    var responseType: ResponseDescribing.Type { get }
}

// MARK: - Response

protocol ResponseDescribing {
    var httpURLResponse: HTTPURLResponse { get }
    init(data: Data?, httpURLResponse: HTTPURLResponse) throws
}
