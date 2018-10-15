import Foundation

// https://www.w3.org/TR/micropub/#error-response
struct MicroPubError: Codable {
    let error: String
    let errorDescription: String?
    
    private enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}
