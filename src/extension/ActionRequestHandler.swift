import Foundation
import AppKit

/// Handler for extension requests
class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    /// Handle an extension request
    /// - Parameter context: The extension context
    func beginRequest(with context: NSExtensionContext) {
        // Check if clipboard contains an image
        guard ClipboardManager.shared.hasImage() else {
            // No image in clipboard, disable menu item
            context.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        
        // Invoke main application to process the image
        invokeMainApplication()
        
        // Complete the extension request
        context.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    /// Invoke the main application to process the image
    private func invokeMainApplication() {
        // Use a custom URL scheme to launch the main application
        // The URL scheme should be defined in the main application's Info.plist
        let url = URL(string: "pasteAsText://process")!
        
        // Open the URL to launch the main application
        NSWorkspace.shared.open(url)
    }
}

/// Extension to check if the extension is valid for the current context
extension ActionRequestHandler {
    /// Validate the extension menu item
    /// - Parameters:
    ///   - command: The command
    ///   - menuItem: The menu item
    /// - Returns: True if the menu item should be enabled
    static func validateMenuItem(_ command: String, menuItem: NSMenuItem) -> Bool {
        // Only enable the menu item if the clipboard contains an image
        return ClipboardManager.shared.hasImage()
    }
}