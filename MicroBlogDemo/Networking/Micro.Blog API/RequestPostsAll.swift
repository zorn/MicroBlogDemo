import Foundation

struct RequestPostsAll: RequestDescribing {
    let method = HTTPMethod.get
    let path = "/posts/all"
    let headers: [[String : String]]? = nil
    let body: String? = nil
}
