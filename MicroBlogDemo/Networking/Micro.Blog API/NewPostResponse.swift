import Foundation

struct NewPostResponse: ResponseDescribing {
    
    let httpURLResponse: HTTPURLResponse
    let error: MicroPubError?
    
    init(data: Data?, httpURLResponse: HTTPURLResponse) throws {
        self.httpURLResponse = httpURLResponse
        
        guard let data = data, data.count > 0 else {
            self.error = nil
            return
        }
        
        self.error = try JSONFeed.Tools.standardDecoder.decode(MicroPubError.self, from: data)
    }
}
