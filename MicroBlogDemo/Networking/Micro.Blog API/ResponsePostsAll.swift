import Foundation

struct ResponsePostsAll: ResponseDescribing {
    
    let jsonFeed: JSONFeed?
    let httpURLResponse: HTTPURLResponse
    
    init(data: Data?, httpURLResponse: HTTPURLResponse) throws {
        self.httpURLResponse = httpURLResponse
        
        guard let data = data else {
            self.jsonFeed = nil
            return
        }
        
        self.jsonFeed = try JSONFeed.Tools.standardDecoder.decode(JSONFeed.self, from: data)
    }
}
 
