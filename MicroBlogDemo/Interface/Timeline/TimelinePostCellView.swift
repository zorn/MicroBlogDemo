import Cocoa

class TimelinePostCellView: NSView {

    static let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TimelinePostCellView")
    
    @IBOutlet var nameTextField: NSTextField?
    @IBOutlet var contentTextView: NSTextView?
    @IBOutlet var dateTextField: NSTextField?
    
    var content: JSONFeed.Item? {
        didSet {
            nameTextField?.stringValue = content?.author?.name ?? "NAME"
            contentTextView?.string = content?.contentHTML ?? ""
            
            if let date = content?.dateModified {
                let dateFormatter = DateFormatter()
                dateTextField?.stringValue = dateFormatter.string(from: date)
            }
            
        }
    }
    
}
