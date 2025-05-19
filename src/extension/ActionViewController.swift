import Cocoa

class ActionViewController: NSViewController {
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start the progress indicator
        progressIndicator.startAnimation(nil)
        
        // Process the image
        processImage()
    }
    
    private func processImage() {
        // In a real implementation, this would process the image from the clipboard
        // and extract text using the selected AI service
        
        // For now, we'll just simulate the process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.statusLabel.stringValue = "Text extracted successfully!"
            
            // Stop the progress indicator
            self.progressIndicator.stopAnimation(nil)
            
            // Close the extension after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.dismiss(nil)
            }
        }
    }
    
    override func dismiss(_ sender: Any?) {
        // Complete the extension request
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}