import Foundation

struct RequestPostsAll: RequestDescribing {
    let method = HTTPMethod.get
    let path = "/posts/all"
    let headers: [[String : String]]? = nil
    let body: Data? = nil
    let responseType: ResponseDescribing.Type = ResponsePostsAll.self
}
