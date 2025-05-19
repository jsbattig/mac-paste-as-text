import Foundation
import AppKit

/// Utility class for clipboard operations
class ClipboardManager {
    /// Shared instance (singleton)
    static let shared = ClipboardManager()
    
    /// The system pasteboard
    private let pasteboard = NSPasteboard.general
    
    /// Private initializer for singleton
    private init() {}
    
    /// Check if the clipboard contains an image
    /// - Returns: True if the clipboard contains an image
    func hasImage() -> Bool {
        return pasteboard.canReadObject(forClasses: [NSImage.self], options: nil)
    }
    
    /// Get an image from the clipboard
    /// - Returns: ImageContent if an image is available, nil otherwise
    func getImageFromClipboard() -> ImageContent? {
        guard let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            return nil
        }
        
        return ImageContent(image: image, source: .clipboard)
    }
    
    /// Write text to the clipboard
    /// - Parameter text: The text to write
    /// - Returns: True if successful
    @discardableResult
    func writeTextToClipboard(_ text: String) -> Bool {
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .string)
    }
    
    /// Write extracted text to the clipboard
    /// - Parameter extractedText: The ExtractedText value object
    /// - Returns: True if successful
    @discardableResult
    func writeExtractedTextToClipboard(_ extractedText: ExtractedText) -> Bool {
        return writeTextToClipboard(extractedText.content)
    }
    
    /// Check if the clipboard contains text
    /// - Returns: True if the clipboard contains text
    func hasText() -> Bool {
        return pasteboard.canReadObject(forClasses: [NSString.self], options: nil)
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
    
    /// Get the types of content available in the clipboard
    /// - Returns: Array of UTI strings representing the content types
    func getAvailableTypes() -> [NSPasteboard.PasteboardType] {
        return pasteboard.types ?? []
    }
    
    /// Check if the clipboard has changed since the last check
    /// - Parameter changeCount: The previous change count to compare against
    /// - Returns: True if the clipboard has changed
    func hasClipboardChanged(since changeCount: Int) -> Bool {
        return pasteboard.changeCount != changeCount
    }
    
    /// Get the current clipboard change count
    /// - Returns: The current change count
    func getChangeCount() -> Int {
        return pasteboard.changeCount
    }
    
    /// Save the current clipboard content to restore later
    /// - Returns: A ClipboardBackup object that can be used to restore the clipboard
    func saveClipboard() -> ClipboardBackup {
        var itemDataByType: [NSPasteboard.PasteboardType: Data] = [:]
        
        if let types = pasteboard.types {
            for type in types {
                if let data = pasteboard.data(forType: type) {
                    itemDataByType[type] = data
                }
            }
        }
        
        return ClipboardBackup(itemDataByType: itemDataByType)
    }
    
    /// Restore the clipboard from a backup
    /// - Parameter backup: The ClipboardBackup to restore from
    /// - Returns: True if successful
    @discardableResult
    func restoreClipboard(from backup: ClipboardBackup) -> Bool {
        pasteboard.clearContents()
        
        let itemDataByType = backup.itemDataByType
        if itemDataByType.isEmpty {
            return true // Nothing to restore
        }
        
        for (type, data) in itemDataByType {
            pasteboard.setData(data, forType: type)
        }
        
        return true
    }
}

/// Structure to hold clipboard backup data
struct ClipboardBackup {
    /// Dictionary mapping pasteboard types to data
    let itemDataByType: [NSPasteboard.PasteboardType: Data]
    
    /// Check if the backup is empty
    var isEmpty: Bool {
        return itemDataByType.isEmpty
    }
}