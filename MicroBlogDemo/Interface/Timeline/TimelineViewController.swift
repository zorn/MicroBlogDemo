import Cocoa
import WebKit

class TimelineViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView!
    
    var items: [JSONFeed.Item] = []
    var itemCellViews: [TimelinePostWebViewCellView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDemoContent()
    }
    
    private func loadDemoContent() {
        if let url = Bundle.main.url(forResource: "timeline-example", withExtension: "json") {
            let data = try! Data(contentsOf: url)
            let feed = try! JSONFeed.Tools.standardDecoder.decode(JSONFeed.self, from: data)
            items = feed.items
            buildViewCells()
        }
    }
    
    func loadFromNib(nibName: String) -> NSView? {
        var topLevelObjects: NSArray?
        if Bundle.main.loadNibNamed(nibName, owner: self, topLevelObjects: &topLevelObjects) {
            return topLevelObjects?.first(where: { $0 is NSView } ) as? NSView
        } else {
            return nil
        }
    }
    
    private func buildViewCells() {
        for item in items {
            print("building cell view for item: \(item)")
            guard let cellView: TimelinePostWebViewCellView = loadFromNib(nibName: "TimelinePostWebViewCellView") as? TimelinePostWebViewCellView else {
                break
            }
            
            // Make sure WebView is present and we are it's loading delegate.
            guard let webView = cellView.webView else {
                return
            }
            webView.navigationDelegate = self
            
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
            let html = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, shrink-to-fit=no'></head><body><div id='size_div'>\(content)</div></body></html>"
            
            // Load the HTML content into the WebView.
            // When it's done loading we'll figure out the height.
            guard let _ = webView.loadHTMLString(html, baseURL: nil) else {
                assertionFailure("no navigation returned")
                return
            }
        }
    }
    
    func finishLoadingCellViewsCheck() {
        let cellsLoaded = itemCellViews.filter({ $0.height > 0}).count == items.count
        print("finishLoadingCellViewsCheck(), cellsLoaded: \(cellsLoaded)")
        if cellsLoaded {
            tableView.reloadData()
        }
    }
    
    func reloadCellViews() {
        itemCellViews = []
        buildViewCells()
    }
}

// MARK: - NSTableViewDataSource, NSTableViewDelegate
extension TimelineViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return itemCellViews.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = itemCellViews[safe: row] else {
            return nil
        }
        return cellView
    }
    
    func cellViewForWebView(_ webView: WKWebView) -> TimelinePostWebViewCellView? {
        return itemCellViews.first(where: { $0.webView === webView })
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let cellView = itemCellViews[safe: row] else {
            return 0
        }
        return cellView.height
    }
}

// MARK: - WKNavigationDelegate
extension TimelineViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("webview did finish")
        
        guard let cellView = cellViewForWebView(webView) else {
            assertionFailure("No cell view found for web view.")
            return
        }
        
        let script = "Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight)"
        webView.evaluateJavaScript(script, completionHandler: { [weak cellView, weak self] (result, error) in
            if let result = result as? CGFloat {
                print("height assigned: \(result)")

                cellView?.height = result
                self?.finishLoadingCellViewsCheck()
            }
        })
    }
}

// TODO: If we like these, consider moving to their own file.

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

