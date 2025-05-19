import Foundation
import AppKit

/// Clipboard manager for handling clipboard operations
/// Implemented following TDD principles
class ClipboardManagerTDD {
    /// Shared instance (singleton)
    static let shared = ClipboardManagerTDD()
    
    /// The system pasteboard
    private let pasteboard = NSPasteboard.general
    
    /// Private initializer for singleton
    private init() {}
    
    /// Write text to the clipboard
    /// - Parameter text: The text to write
    /// - Returns: True if successful
    @discardableResult
    func writeTextToClipboard(_ text: String) -> Bool {
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .string)
    }
    
    /// Get text from the clipboard
    /// - Returns: The text if available, nil otherwise
    func getTextFromClipboard() -> String? {
        return pasteboard.string(forType: .string)
    }
    
    /// Clear the clipboard
    func clearClipboard() {
        pasteboard.clearContents()
    }
    
    /// Check if the clipboard contains text
    /// - Returns: True if the clipboard contains text
    func hasText() -> Bool {
        return pasteboard.canReadObject(forClasses: [NSString.self], options: nil)
    }
    
    /// Get the current clipboard change count
    /// - Returns: The current change count
    func getChangeCount() -> Int {
        return pasteboard.changeCount
    }
    
    /// Check if the clipboard has changed since the last check
    /// - Parameter changeCount: The previous change count to compare against
    /// - Returns: True if the clipboard has changed
    func hasClipboardChanged(since changeCount: Int) -> Bool {
        return pasteboard.changeCount != changeCount
    }
}