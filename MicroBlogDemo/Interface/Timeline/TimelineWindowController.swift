import Cocoa

class TimelineWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let vc = TimelineViewController()
        contentViewController = vc
    }

}
