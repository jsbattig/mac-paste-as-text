import Foundation
import AppKit

/// Entity representing an image from the clipboard
class ImageContent {
    /// Unique identifier for the image
    let id: UUID
    
    /// The image data
    private let image: NSImage
    
    /// The date when the image was created/captured
    let createdAt: Date
    
    /// The source of the image (e.g., clipboard, file)
    let source: ImageSource
    
    /// The mime type of the image if known
    var mimeType: String?
    
    /// Initialize with an image
    /// - Parameters:
    ///   - image: The image
    ///   - source: The source of the image
    ///   - id: Optional UUID (will be generated if not provided)
    ///   - createdAt: Optional creation date (will use current date if not provided)
    init(image: NSImage, source: ImageSource, id: UUID = UUID(), createdAt: Date = Date()) {
        self.image = image
        self.source = source
        self.id = id
        self.createdAt = createdAt
        
        // Try to determine mime type from image data
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData) {
            if bitmap.canBeCompressed(using: .jpeg) {
                self.mimeType = "image/jpeg"
            } else if bitmap.canBeCompressed(using: .png) {
                self.mimeType = "image/png"
            }
        }
    }
    
    /// Get the image
    /// - Returns: The NSImage
    func getImage() -> NSImage {
        return image
    }
    
    /// Get the image data in the specified format
    /// - Parameter format: The desired image format
    /// - Returns: The image data or nil if conversion fails
    func getImageData(format: NSBitmapImageRep.FileType = .jpeg) -> Data? {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        return bitmap.representation(using: format, properties: [:])
    }
    
    /// Get the image as base64 encoded string
    /// - Parameter format: The desired image format
    /// - Returns: Base64 encoded string or nil if conversion fails
    func getBase64EncodedString(format: NSBitmapImageRep.FileType = .jpeg) -> String? {
        guard let imageData = getImageData(format: format) else {
            return nil
        }
        
        return imageData.base64EncodedString()
    }
    
    /// Get the dimensions of the image
    /// - Returns: The size of the image
    func getDimensions() -> CGSize {
        return image.size
    }
}

/// Enum representing the source of an image
enum ImageSource {
    /// Image from the clipboard
    case clipboard
    
    /// Image from a file
    case file(URL)
    
    /// Image from a URL
    case url(URL)
    
    /// Custom source
    case custom(String)
}