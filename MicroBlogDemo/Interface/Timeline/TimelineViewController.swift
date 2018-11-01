import Cocoa
import WebKit

class TimelineViewController: NSViewController {
    
    @IBOutlet var webView: WKWebView?
    @IBOutlet var appTokenTextField: NSTextField?

    var items: [JSONFeed.Item] = []
    var htmlContent: String = ""
    var serverConnection: ServerConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appTokenTextField?.stringValue = "8411BE13192189E3F427" // Invalidate and remove in time.
        serverConnection = ServerConnection(configuration: MicroBlogConfiguration())
        fetchPosts()
    }
    
    @IBAction func reload(sender: NSButton) {
        fetchPosts()
    }
    
    private func fetchPosts() {
        
        guard let appToken = appTokenTextField?.stringValue else { return }
        
        try! serverConnection?.logIn(appToken: appToken)
        let request = RequestPostsAll()
        serverConnection?.execute(request) { (response, error) in
            
            if let error = error {
                print("Had error loading posts: \(error)")
                return
            }
            
            if let response = response as? ResponsePostsAll, let items = response.jsonFeed?.items {
                DispatchQueue.main.async {
                    self.items = items
                    self.buildPageContent()
                    self.webView?.loadHTMLString(self.htmlContent, baseURL: nil)
                    try! self.serverConnection?.logOut()
                }
            }
        }
    }
    
    private func buildPageContent() {
        var postContent = ""
        for item in items {
            
            // Figure out the HTML content to load.
            let content: String
            if let contentHTML = item.contentHTML {
                content = contentHTML
            } else if let contentText = item.contentText {
                // At the moment I believe all Micro.Blog content comes back as HTML.
                // If that changes we might want to do a little processing here to make the plain text render better in a web view
                // or give it its own cell type.
                content = contentText
            } else {
                assertionFailure("This should not happen according to the JSONFeed spec.")
                content = ""
            }
            
            postContent += content
            postContent += "<hr />"
        }
        
        htmlContent = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, shrink-to-fit=no'></head><body><div id='size_div'>\(postContent)</div></body></html>"
    }
}
