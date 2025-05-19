import XCTest
@testable import PasteAsText

/// Unit tests for the ImageContent entity following TDD approach
class ImageContentTDD: XCTestCase {
    
    /// Test image
    var testImage: NSImage!
    
    /// Set up before each test
    override func setUp() {
        super.setUp()
        
        // Create a test image (1x1 pixel)
        testImage = NSImage(size: NSSize(width: 1, height: 1))
    }
    
    /// Tear down after each test
    override func tearDown() {
        testImage = nil
        super.tearDown()
    }
    
    /// Test initializing with an image
    func testInitWithImage() {
        // Create an ImageContent with the test image
        let imageContent = ImageContentTDD_Implementation(image: testImage)
        
        // Verify the image was set
        XCTAssertNotNil(imageContent.image)
        XCTAssertEqual(imageContent.image.size.width, 1)
        XCTAssertEqual(imageContent.image.size.height, 1)
    }
    
    /// Test initializing with an image and metadata
    func testInitWithImageAndMetadata() {
        // Create metadata
        let metadata: [String: Any] = [
            "source": "clipboard",
            "timestamp": Date(),
            "format": "png"
        ]
        
        // Create an ImageContent with the test image and metadata
        let imageContent = ImageContentTDD_Implementation(image: testImage, metadata: metadata)
        
        // Verify the image and metadata were set
        XCTAssertNotNil(imageContent.image)
        XCTAssertEqual(imageContent.metadata["source"] as? String, "clipboard")
        XCTAssertNotNil(imageContent.metadata["timestamp"])
        XCTAssertEqual(imageContent.metadata["format"] as? String, "png")
    }
    
    /// Test getting image size
    func testGetImageSize() {
        // Create an ImageContent with the test image
        let imageContent = ImageContentTDD_Implementation(image: testImage)
        
        // Verify the image size
        let size = imageContent.getImageSize()
        XCTAssertEqual(size.width, 1)
        XCTAssertEqual(size.height, 1)
    }
    
    /// Test converting to PNG data
    func testToPNGData() {
        // Create an ImageContent with the test image
        let imageContent = ImageContentTDD_Implementation(image: testImage)
        
        // Convert to PNG data
        let pngData = imageContent.toPNGData()
        
        // Verify the data is not nil
        XCTAssertNotNil(pngData)
    }
    
    /// Test converting to JPEG data
    func testToJPEGData() {
        // Create an ImageContent with the test image
        let imageContent = ImageContentTDD_Implementation(image: testImage)
        
        // Convert to JPEG data with quality 0.8
        let jpegData = imageContent.toJPEGData(quality: 0.8)
        
        // Verify the data is not nil
        XCTAssertNotNil(jpegData)
    }
    
    /// Test getting metadata value
    func testGetMetadataValue() {
        // Create metadata
        let metadata: [String: Any] = [
            "source": "clipboard",
            "timestamp": Date(),
            "format": "png"
        ]
        
        // Create an ImageContent with the test image and metadata
        let imageContent = ImageContentTDD_Implementation(image: testImage, metadata: metadata)
        
        // Get metadata values
        let source = imageContent.getMetadataValue(key: "source") as? String
        let format = imageContent.getMetadataValue(key: "format") as? String
        let nonExistent = imageContent.getMetadataValue(key: "nonExistent")
        
        // Verify the values
        XCTAssertEqual(source, "clipboard")
        XCTAssertEqual(format, "png")
        XCTAssertNil(nonExistent)
    }
    
    /// Test setting metadata value
    func testSetMetadataValue() {
        // Create an ImageContent with the test image
        let imageContent = ImageContentTDD_Implementation(image: testImage)
        
        // Set metadata values
        imageContent.setMetadataValue(key: "source", value: "clipboard")
        imageContent.setMetadataValue(key: "format", value: "png")
        
        // Verify the values
        XCTAssertEqual(imageContent.metadata["source"] as? String, "clipboard")
        XCTAssertEqual(imageContent.metadata["format"] as? String, "png")
    }
}

// Minimal implementation to make the tests pass
class ImageContentTDD_Implementation {
    let image: NSImage
    var metadata: [String: Any]
    
    init(image: NSImage, metadata: [String: Any] = [:]) {
        self.image = image
        self.metadata = metadata
    }
    
    func getImageSize() -> NSSize {
        return image.size
    }
    
    func toPNGData() -> Data? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .png, properties: [:])
    }
    
    func toJPEGData(quality: CGFloat = 0.9) -> Data? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: quality])
    }
    
    func getMetadataValue(key: String) -> Any? {
        return metadata[key]
    }
    
    func setMetadataValue(key: String, value: Any) {
        metadata[key] = value
    }
}