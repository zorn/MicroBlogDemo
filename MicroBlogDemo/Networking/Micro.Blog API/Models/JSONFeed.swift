import Foundation

/// The JSON Feed format is a pragmatic syndication format, like RSS and Atom, but with one big difference: it’s JSON instead of XML.
/// https://jsonfeed.org/version/1
struct JSONFeed: Codable {
    
    /// The URL of the version of the format the feed uses. This should appear at the very top, though we recognize that not all JSON generators allow for ordering.
    let version: String
    
    /// The name of the feed, which will often correspond to the name of the website (blog, for instance), though not necessarily.
    let title: String
    
    /// The URL of the resource that the feed describes. This resource may or may not actually be a “home” page, but it should be an HTML page. If a feed is published on the public web, this should be considered as required. But it may not make sense in the case of a file created on a desktop computer, when that file is not shared or is shared only privately.
    let homePageURL: URL?

    /// The URL of the feed, and serves as the unique identifier for the feed. As with home_page_url, this should be considered required for feeds on the public web.
    let feedURL: URL?
    
    /// Provides more detail, beyond the title, on what the feed is about. A feed reader may display this text.
    let description: String?
    
    /// A description of the purpose of the feed. This is for the use of people looking at the raw JSON, and should be ignored by feed readers.
    let userComment: String?
    
    /// The URL of a feed that provides the next n items, where n is determined by the publisher. This allows for pagination, but with the expectation that reader software is not required to use it and probably won’t use it very often. next_url must not be the same as feed_url, and it must not be the same as a previous next_url (to avoid infinite loops).
    let nextURL: URL?
    
    /// The URL of an image for the feed suitable to be used in a timeline, much the way an avatar might be used. It should be square and relatively large — such as 512 x 512 — so that it can be scaled-down and so that it can look good on retina displays. It should use transparency where appropriate, since it may be rendered on a non-white background.
    let iconURL: URL?
    
    /// The URL of an image for the feed suitable to be used in a source list. It should be square and relatively small, but not smaller than 64 x 64 (so that it can look good on retina displays). As with icon, this image should use transparency where appropriate, since it may be rendered on a non-white background.
    let faviconURL: URL?
    
    /// Specifies the feed author.
    let author: Author?
    
    /// Says whether or not the feed is finished — that is, whether or not it will ever update again. A feed for a temporary event, such as an instance of the Olympics, could expire. If the value is true, then it’s expired. Any other value, or the absence of expired, means the feed may continue to update.
    let expiried: Bool?

    // TBI: hubs (very optional, array of objects) describes endpoints that can be used to subscribe to real-time notifications from the publisher of this feed. Each object has a type and url, both of which are required. See the section “Subscribing to Real-time Notifications” below for details.
    
    /// The non-optional collection of items.
    let items: [JSONFeed.Item]

    private enum CodingKeys: String, CodingKey {
        case version
        case title
        case homePageURL = "home_page_url"
        case feedURL = "feed_url"
        case description
        case userComment = "user_comment"
        case nextURL = "next_url"
        case iconURL = "icon"
        case faviconURL = "favicon"
        case author
        case expiried
        case items
    }
}

extension JSONFeed {
    struct Item: Codable {
        
        /// An id is unique for that item for that feed over time. If an item is ever updated, the id should be unchanged. New items should never use a previously-used id. If an id is presented as a number or other type, a JSON Feed reader must coerce it to a string. Ideally, the id is the full URL of the resource described by the item, since URLs make great unique identifiers.
        let id: String
        
        /// The URL of the resource described by the item. It’s the permalink. This may be the same as the id — but should be present regardless.
        let url: URL?
        
        /// The URL of a page elsewhere. This is especially useful for linkblogs. If url links to where you’re talking about a thing, then external_url links to the thing you’re talking about.
        let externalURL: URL?
        
        /// A title is plain text. Microblog items in particular may omit titles.
        let title: String?
        
        /// content_html and content_text are each optional strings — but one or both must be present. This is the HTML or plain text of the item. Important: the only place HTML is allowed in this format is in content_html. A Twitter-like service might use content_text, while a blog might use content_html. Use whichever makes sense for your resource. (It doesn’t even have to be the same for each item in a feed.)
        let contentHTML: String?
        
        /// content_html and content_text are each optional strings — but one or both must be present. This is the HTML or plain text of the item. Important: the only place HTML is allowed in this format is in content_html. A Twitter-like service might use content_text, while a blog might use content_html. Use whichever makes sense for your resource. (It doesn’t even have to be the same for each item in a feed.)
        let contentText: String?
        
        /// a plain text sentence or two describing the item. This might be presented in a timeline, for instance, where a detail view would display all of content_html or content_text.
        let summary: String?

        /// the URL of the main image for the item. This image may also appear in the content_html — if so, it’s a hint to the feed reader that this is the main, featured image. Feed readers may use the image as a preview (probably resized as a thumbnail and placed in a timeline).
        let imageURL: URL?
        
        /// The URL of an image to use as a banner. Some blogging systems (such as Medium) display a different banner image chosen to go with each post, but that image wouldn’t otherwise appear in the content_html. A feed reader with a detail view may choose to show this banner image at the top of the detail view, possibly with the title overlaid.
        let bannerImageURL: URL?
        
        /// Specifies the date in RFC 3339 format. (Example: 2010-02-07T14:04:00-05:00.)
        let datePublished: Date?
        
        /// Specifies the modification date in RFC 3339 format. (Example: 2010-02-07T14:04:00-05:00.)
        let dateModified: Date?
        
        /// Has the same structure as the JSONFeed.Info author. If not specified in an item, then the top-level author, if present, is the author of the item.
        let author: Author?
        
        /// Can have any plain text values you want. Tags tend to be just one word, but they may be anything. Note: they are not the equivalent of Twitter hashtags. Some blogging systems and other feed formats call these categories.
        let tags: [String]?
        
        /// An individual item may have one or more attachments.
        let attachments: [JSONFeed.Attachment]?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case url
            case externalURL = "external_url"
            case title
            case contentHTML = "content_html"
            case contentText = "content_text"
            case summary
            case imageURL = "image"
            case bannerImageURL = "banner_image"
            case datePublished = "date_published"
            case dateModified = "date_modified"
            case author
            case tags
            case attachments
        }
    }
}

extension JSONFeed {
    struct Author: Codable {
        
        /// The author’s name.
        let name: String?
        
        /// The URL of a site owned by the author. It could be a blog, micro-blog, Twitter account, and so on. Ideally the linked-to page provides a way to contact the author, but that’s not required. The URL could be a mailto: link, though we suspect that will be rare.
        let url: URL?
        
        /// the URL for an image for the author. As with icon, it should be square and relatively large — such as 512 x 512 — and should use transparency where appropriate, since it may be rendered on a non-white background.
        let avatarURL: URL?
        
        private enum CodingKeys: String, CodingKey {
            case name
            case url
            case avatarURL = "avatar"
        }
    }
}

extension JSONFeed {
    struct Attachment: Codable {
        
        /// specifies the location of the attachment.
        let url: String
        
        /// specifies the type of the attachment, such as “audio/mpeg.”
        let mimeType: String
        
        /// a name for the attachment. Important: if there are multiple attachments, and two or more have the exact same title (when title is present), then they are considered as alternate representations of the same thing. In this way a podcaster, for instance, might provide an audio recording in different formats.
        let title: String?
        
        /// specifies how large the file is.
        let sizeInBytes: Int?
        
        /// specifies how long it takes to listen to or watch, when played at normal speed.
        let durationInSeconds: Int?
        
        private enum CodingKeys: String, CodingKey {
            case url
            case mimeType = "mime_type"
            case title
            case sizeInBytes = "size_in_bytes"
            case durationInSeconds = "duration_in_seconds"
        }
    }
}

extension JSONFeed {
    
    struct Tools {
        
        static var standardDecoder: JSONDecoder {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(JSONFeed.Formatters.dateFormatter)
            return decoder
        }
    }
    
    struct Formatters {
        
        /// A dateFormatter for the expected RFC 3339 format
        static var dateFormatter: DateFormatter {
            let f = DateFormatter()
            f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
            return f
        }
    }
}
