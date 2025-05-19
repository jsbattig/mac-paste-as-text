import Foundation
import AppKit

/// Entity representing an image from the clipboard
/// Implemented following TDD principles
class ImageContentTDD {
    /// The image
    let image: NSImage
    
    /// Metadata associated with the image
    var metadata: [String: Any]
    
    /// Initialize with an image
    /// - Parameter image: The image
    /// - Parameter metadata: Optional metadata
    init(image: NSImage, metadata: [String: Any] = [:]) {
        self.image = image
        self.metadata = metadata
    }
    
    /// Get the size of the image
    /// - Returns: The size of the image
    func getImageSize() -> NSSize {
        return image.size
    }
    
    /// Convert the image to PNG data
    /// - Returns: PNG data representation of the image, or nil if conversion fails
    func toPNGData() -> Data? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .png, properties: [:])
    }
    
    /// Convert the image to JPEG data
    /// - Parameter quality: The compression quality (0.0 to 1.0)
    /// - Returns: JPEG data representation of the image, or nil if conversion fails
    func toJPEGData(quality: CGFloat = 0.9) -> Data? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: quality])
    }
    
    /// Get a metadata value
    /// - Parameter key: The metadata key
    /// - Returns: The metadata value, or nil if not found
    func getMetadataValue(key: String) -> Any? {
        return metadata[key]
    }
    
    /// Set a metadata value
    /// - Parameters:
    ///   - key: The metadata key
    ///   - value: The metadata value
    func setMetadataValue(key: String, value: Any) {
        metadata[key] = value
    }
    
    /// Create a copy of the image content
    /// - Returns: A new ImageContentTDD instance with the same image and metadata
    func copy() -> ImageContentTDD {
        return ImageContentTDD(image: image, metadata: metadata)
    }
    
    /// Create a resized copy of the image content
    /// - Parameter size: The new size
    /// - Returns: A new ImageContentTDD instance with the resized image
    func resized(to size: NSSize) -> ImageContentTDD {
        let resizedImage = NSImage(size: size)
        
        resizedImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: size),
                  from: NSRect(origin: .zero, size: image.size),
                  operation: .copy,
                  fraction: 1.0)
        resizedImage.unlockFocus()
        
        var newMetadata = metadata
        newMetadata["originalSize"] = NSStringFromSize(image.size)
        newMetadata["resizedSize"] = NSStringFromSize(size)
        
        return ImageContentTDD(image: resizedImage, metadata: newMetadata)
    }
    
    /// Create a cropped copy of the image content
    /// - Parameter rect: The rectangle to crop to
    /// - Returns: A new ImageContentTDD instance with the cropped image
    func cropped(to rect: NSRect) -> ImageContentTDD? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        guard imageRect.contains(rect) else {
            return nil
        }
        
        // Convert to CGRect with flipped coordinates
        let flippedRect = CGRect(
            x: rect.origin.x,
            y: image.size.height - rect.origin.y - rect.size.height,
            width: rect.size.width,
            height: rect.size.height
        )
        
        guard let croppedCGImage = cgImage.cropping(to: flippedRect) else {
            return nil
        }
        
        let croppedImage = NSImage(cgImage: croppedCGImage, size: rect.size)
        
        var newMetadata = metadata
        newMetadata["originalSize"] = NSStringFromSize(image.size)
        newMetadata["cropRect"] = NSStringFromRect(rect)
        
        return ImageContentTDD(image: croppedImage, metadata: newMetadata)
    }
    
    /// Check if the image has alpha channel (transparency)
    /// - Returns: True if the image has alpha channel
    func hasAlphaChannel() -> Bool {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return false
        }
        
        let alphaInfo = cgImage.alphaInfo
        return alphaInfo != .none && alphaInfo != .noneSkipLast && alphaInfo != .noneSkipFirst
    }
    
    /// Get the average color of the image
    /// - Returns: The average color, or nil if calculation fails
    func getAverageColor() -> NSColor? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let totalPixels = width * height
        
        guard totalPixels > 0 else {
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else {
            return nil
        }
        
        let dataPtr = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        var totalAlpha = 0
        
        for i in 0..<totalPixels {
            let pixelOffset = i * 4
            totalRed += Int(dataPtr[pixelOffset])
            totalGreen += Int(dataPtr[pixelOffset + 1])
            totalBlue += Int(dataPtr[pixelOffset + 2])
            totalAlpha += Int(dataPtr[pixelOffset + 3])
        }
        
        let avgRed = CGFloat(totalRed) / CGFloat(totalPixels) / 255.0
        let avgGreen = CGFloat(totalGreen) / CGFloat(totalPixels) / 255.0
        let avgBlue = CGFloat(totalBlue) / CGFloat(totalPixels) / 255.0
        let avgAlpha = CGFloat(totalAlpha) / CGFloat(totalPixels) / 255.0
        
        return NSColor(red: avgRed, green: avgGreen, blue: avgBlue, alpha: avgAlpha)
    }
}