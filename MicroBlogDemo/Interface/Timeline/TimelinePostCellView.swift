import Cocoa

class TimelinePostCellView: NSView {

    static let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TimelinePostCellView")
    
    @IBOutlet var nameTextField: NSTextField?
    @IBOutlet var contentTextView: NSTextView?
    @IBOutlet var contentTextViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet var dateTextField: NSTextField?
    
    var content: JSONFeed.Item? {
        didSet {
            nameTextField?.stringValue = content?.author?.name ?? "NAME"
            
            let ccc = content?.contentHTML ?? ""
            let trimmedContent = ccc.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            contentTextView?.string = trimmedContent
            
            if let date = content?.dateModified {
                let dateFormatter = DateFormatter()
                dateTextField?.stringValue = dateFormatter.string(from: date)
            }
        }
    }
    
    override func layout() {
        super.layout()
        if
            let container = contentTextView?.textContainer,
            let range = contentTextView?.layoutManager?.glyphRange(for: container),
            let height = contentTextView?.layoutManager?.boundingRect(forGlyphRange: range, in: container).size.height
        {
            contentTextViewHeightConstraint?.constant = height + 2
        }
        super.layout()
    }
    
}
