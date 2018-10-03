import Foundation

struct MicroBlogConfiguration: ServerConnectionConfiguration {
    let host: URL = URL(string: "https://micro.blog")!
}
