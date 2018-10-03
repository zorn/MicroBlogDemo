import XCTest
@testable import MicroBlogDemo

class JSONFeedTests: XCTestCase {

    // test_methodName_withCertainState_shouldDoSomething
    
    func test_canEncodeAndDecode_withValidTopLevelProperties() {
        let version = "https://jsonfeed.org/version/1"
        let title = "JSON Feed Title"
        let homePageURL = URL(string: "https://jsonfeed.org")!
        let feedURL = URL(string: "https://micro.blog/posts/all")!
        
        // encode
        let jsonFeed = JSONFeed(version: version, title: title, homePageURL: homePageURL, feedURL: feedURL, description: nil, userComment: nil, nextURL: nil, iconURL: nil, faviconURL: nil, author: nil, expiried: nil, items: [])
        
        let data = try! JSONEncoder().encode(jsonFeed)
        
        // decode
        let decodedFeed = try! JSONDecoder().decode(JSONFeed.self, from: data)
        
        // verify
        XCTAssertEqual(decodedFeed.version, jsonFeed.version)
        XCTAssertEqual(decodedFeed.title, jsonFeed.title)
        XCTAssertEqual(decodedFeed.homePageURL, jsonFeed.homePageURL)
        XCTAssertEqual(decodedFeed.feedURL, jsonFeed.feedURL)
    }
    
    func test_canDecodeSampleFile_withValidTopLevelProperties() {
        let bundle = Bundle(for: JSONFeedTests.self)
        let sampleFileURL = bundle.url(forResource: "info-sample", withExtension: "json")!
        let data = try! Data(contentsOf: sampleFileURL)
        let decodedFeed = try! JSONDecoder().decode(JSONFeed.self, from: data)
        XCTAssertEqual(decodedFeed.version, "https://jsonfeed.org/version/1")
        XCTAssertEqual(decodedFeed.title, "JSON Feed Title")
        XCTAssertEqual(decodedFeed.homePageURL, URL(string: "https://jsonfeed.org")!)
        XCTAssertEqual(decodedFeed.feedURL, URL(string: "https://micro.blog/posts/all")!)
    }
    
    func test_importingPostsAllMicroBlogSample_shouldResultInValidJSONFeedObject() {
        let bundle = Bundle(for: JSONFeedTests.self)
        let sampleFileURL = bundle.url(forResource: "posts-all", withExtension: "json")!
        let data = try! Data(contentsOf: sampleFileURL)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(JSONFeed.Formatters.dateFormatter)
        let jsonFeed = try! decoder.decode(JSONFeed.self, from: data)
        
        XCTAssertEqual(jsonFeed.version, "https://jsonfeed.org/version/1")
        XCTAssertEqual(jsonFeed.title, "Micro.blog - Timeline")
        XCTAssertEqual(jsonFeed.homePageURL, URL(string: "https://micro.blog/")!)
        XCTAssertEqual(jsonFeed.feedURL, URL(string: "https://micro.blog/posts/all")!)
        XCTAssertNil(jsonFeed.description)
        XCTAssertNil(jsonFeed.userComment)
        XCTAssertNil(jsonFeed.nextURL)
        XCTAssertNil(jsonFeed.iconURL)
        XCTAssertNil(jsonFeed.faviconURL)
        XCTAssertNil(jsonFeed.author)
        XCTAssertNil(jsonFeed.expiried)
        
        XCTAssertEqual(jsonFeed.items.count, 40)
        
        let item = jsonFeed.items[0]
        
        XCTAssertEqual(item.id, "928564")
        XCTAssertEqual(item.contentHTML, "<p>I’ve been thinking about using NaNoWriMo to finally finish my Indie Microblogging book, even though it’s not a novel. I wonder if we can do something special on Micro.blog for anyone writing in November. 📚</p>\n")
        XCTAssertEqual(item.url, URL(string: "https://www.manton.org/2018/09/30/ive-been-thinking.html")!)
        XCTAssertEqual(item.datePublished, JSONFeed.Formatters.dateFormatter.date(from: "2018-09-30T22:55:03+00:00")!)
        XCTAssertNil(item.externalURL)
        XCTAssertNil(item.title)
        XCTAssertNil(item.contentText)
        XCTAssertNil(item.summary)
        XCTAssertNil(item.imageURL)
        XCTAssertNil(item.bannerImageURL)
        XCTAssertNil(item.dateModified)
        XCTAssertNil(item.tags)
        XCTAssertNil(item.attachments)
        
        XCTAssertNotNil(item.author)
        XCTAssertEqual(item.author?.name, "Manton Reece")
        XCTAssertEqual(item.author?.url, URL(string: "https://manton.org/")!)
        XCTAssertEqual(item.author?.avatarURL, URL(string: "https://micro.blog/manton/avatar.jpg")!)
    }

}
