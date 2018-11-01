import Cocoa
import WebKit

class TimelinePostWebViewCellView: NSView {

    static let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TimelinePostWebViewCellView")
    
    @IBOutlet var webView: WKWebView?

    /// During the run time we'll need to do some calculations to figure out the height of these cells.
    /// This is a simple property to store the last known height for this cell.
    var height: CGFloat = 0
}
