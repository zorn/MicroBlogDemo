import Foundation

struct NewPostRequest: RequestDescribing {
    let responseType: ResponseDescribing.Type = NewPostResponse.self
    let method = HTTPMethod.post
    let path = "micropub"
    let headers: [[String : String]]? = [
        ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8"]
    ]
    
    var bodyParameters: [String: String] {
        return [
            "h": "entry",
            "content": content,
        ]
    }
    var body: Data? {
        return bodyParameters.queryParameters.data(using: .utf8, allowLossyConversion: true)
    }
    
    let content: String
    
    init(content: String) {
        self.content = content
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}
