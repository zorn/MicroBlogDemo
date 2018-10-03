import XCTest
@testable import MicroBlogDemo

class JSONFeedItemTests: XCTestCase {
    
    // test_methodName_withCertainState_shouldDoSomething
    
    func test_canEncodeAndDecode_withValidInfo() {
        let id = "928564"
        let title = "JSON Feed Title"
        let url = URL(string: "https://www.manton.org/2018/09/30/ive-been-thinking.html")!
        let contentHTML = "<p>I’ve been thinking about using NaNoWriMo to finally finish my Indie Microblogging book, even though it’s not a novel. I wonder if we can do something special on Micro.blog for anyone writing in November. 📚</p>\n"
        let datePublished = JSONFeed.Formatters.dateFormatter.date(from: "2018-09-30T22:55:03+00:00")!
        
        // encode
        let item = JSONFeed.Item(id: id, url: url, externalURL: nil, title: title, contentHTML: contentHTML, contentText: nil, summary: nil, imageURL: nil, bannerImageURL: nil, datePublished: datePublished, dateModified: nil, author: nil, tags: nil, attachments: nil)
        let data = try! JSONEncoder().encode(item)
        
        // decode
        let decodedItem = try! JSONDecoder().decode(JSONFeed.Item.self, from: data)
        
        // verify
        XCTAssertEqual(decodedItem.id, item.id)
        XCTAssertEqual(decodedItem.title, item.title)
        XCTAssertEqual(decodedItem.url, item.url)
        XCTAssertEqual(decodedItem.contentHTML, item.contentHTML)
        XCTAssertEqual(decodedItem.contentText, nil)
        XCTAssertEqual(decodedItem.datePublished, item.datePublished)
    }
    
    func test_canDecodeSampleFile_withValidInfoData() {
        let bundle = Bundle(for: JSONFeedItemTests.self)
        let sampleFileURL = bundle.url(forResource: "item-sample", withExtension: "json")!
        let data = try! Data(contentsOf: sampleFileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(JSONFeed.Formatters.dateFormatter)
        let decodedItem = try! decoder.decode(JSONFeed.Item.self, from: data)
        XCTAssertEqual(decodedItem.id, "928564")
        XCTAssertEqual(decodedItem.title, nil)
        XCTAssertEqual(decodedItem.url, URL(string: "https://www.manton.org/2018/09/30/ive-been-thinking.html")!)
        XCTAssertEqual(decodedItem.contentHTML, "<p>I’ve been thinking about using NaNoWriMo to finally finish my Indie Microblogging book, even though it’s not a novel. I wonder if we can do something special on Micro.blog for anyone writing in November. 📚</p>\n")
        XCTAssertEqual(decodedItem.contentText, nil)
        let datePublished = JSONFeed.Formatters.dateFormatter.date(from: "2018-09-30T22:55:03+00:00")!
        XCTAssertEqual(decodedItem.datePublished, datePublished)
    }

}
