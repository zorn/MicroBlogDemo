import Cocoa

class TimelineViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView!
    
    var items: [JSONFeed.Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDemoContent()
        
        let nib = NSNib(nibNamed: TimelinePostCellView.cellIdentifier.rawValue, bundle: nil)
        tableView.register(nib, forIdentifier: TimelinePostCellView.cellIdentifier)
        
        //tableView.rowHeight = 122.0 // estimated row height
    }
    
    private func loadDemoContent() {
        if let url = Bundle.main.url(forResource: "timeline-example", withExtension: "json") {
            let data = try! Data(contentsOf: url)
            let feed = try! JSONFeed.Tools.standardDecoder.decode(JSONFeed.self, from: data)
            items = feed.items
            tableView.reloadData()
        }
    }
    
}

extension TimelineViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = items[row]
        if let cell = tableView.makeView(withIdentifier: TimelinePostCellView.cellIdentifier, owner: nil) as? TimelinePostCellView {
            cell.content = item
            return cell
        }
        return nil
    }
    
}
