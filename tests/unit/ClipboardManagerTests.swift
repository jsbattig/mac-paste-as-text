import XCTest
@testable import PasteAsText

/// Unit tests for the ClipboardManager
class ClipboardManagerTests: XCTestCase {
    /// The clipboard manager to test
    var clipboardManager: ClipboardManager!
    
    /// Original clipboard content to restore
    var originalClipboardBackup: ClipboardBackup?
    
    /// Set up before each test
    override func setUp() {
        super.setUp()
        clipboardManager = ClipboardManager.shared
        
        // Save original clipboard content
        originalClipboardBackup = clipboardManager.saveClipboard()
        
        // Clear clipboard for tests
        clipboardManager.clearClipboard()
    }
    
    /// Tear down after each test
    override func tearDown() {
        // Restore original clipboard content
        if let backup = originalClipboardBackup {
            clipboardManager.restoreClipboard(from: backup)
        }
        
        super.tearDown()
    }
    
    /// Test writing and reading text from clipboard
    func testWriteAndReadText() {
        // Test text
        let testText = "Hello, World!"
        
        // Write text to clipboard
        let writeResult = clipboardManager.writeTextToClipboard(testText)
        XCTAssertTrue(writeResult, "Writing text to clipboard should succeed")
        
        // Check if clipboard has text
        XCTAssertTrue(clipboardManager.hasText(), "Clipboard should have text")
        
        // Read text from clipboard
        let readText = clipboardManager.getTextFromClipboard()
        XCTAssertEqual(readText, testText, "Read text should match written text")
    }
    
    /// Test writing and reading empty text
    func testWriteAndReadEmptyText() {
        // Empty text
        let emptyText = ""
        
        // Write empty text to clipboard
        let writeResult = clipboardManager.writeTextToClipboard(emptyText)
        XCTAssertTrue(writeResult, "Writing empty text to clipboard should succeed")
        
        // Check if clipboard has text (should be true even for empty text)
        XCTAssertTrue(clipboardManager.hasText(), "Clipboard should have text")
        
        // Read text from clipboard
        let readText = clipboardManager.getTextFromClipboard()
        XCTAssertEqual(readText, emptyText, "Read text should be empty")
    }
    
    /// Test writing ExtractedText to clipboard
    func testWriteExtractedText() {
        // Create ExtractedText
        let extractedText = ExtractedText(
            content: "Extracted text content",
            sourceImageId: UUID(),
            serviceType: .gemini
        )
        
        // Write ExtractedText to clipboard
        let writeResult = clipboardManager.writeExtractedTextToClipboard(extractedText)
        XCTAssertTrue(writeResult, "Writing ExtractedText to clipboard should succeed")
        
        // Read text from clipboard
        let readText = clipboardManager.getTextFromClipboard()
        XCTAssertEqual(readText, extractedText.content, "Read text should match ExtractedText content")
    }
    
    /// Test clearing clipboard
    func testClearClipboard() {
        // Write text to clipboard
        clipboardManager.writeTextToClipboard("Test text")
        
        // Verify clipboard has text
        XCTAssertTrue(clipboardManager.hasText(), "Clipboard should have text")
        
        // Clear clipboard
        clipboardManager.clearClipboard()
        
        // Verify clipboard is empty
        XCTAssertFalse(clipboardManager.hasText(), "Clipboard should be empty after clearing")
    }
    
    /// Test clipboard change count
    func testClipboardChangeCount() {
        // Get initial change count
        let initialChangeCount = clipboardManager.getChangeCount()
        
        // Write to clipboard
        clipboardManager.writeTextToClipboard("Test text")
        
        // Verify change count increased
        XCTAssertTrue(clipboardManager.hasClipboardChanged(since: initialChangeCount), "Clipboard should have changed")
        
        // Get new change count
        let newChangeCount = clipboardManager.getChangeCount()
        XCTAssertGreaterThan(newChangeCount, initialChangeCount, "Change count should increase")
        
        // Verify no change if we don't modify clipboard
        XCTAssertFalse(clipboardManager.hasClipboardChanged(since: newChangeCount), "Clipboard should not have changed")
    }
    
    /// Test saving and restoring clipboard
    func testSaveAndRestoreClipboard() {
        // Write text to clipboard
        let testText = "Test text for backup"
        clipboardManager.writeTextToClipboard(testText)
        
        // Save clipboard
        let backup = clipboardManager.saveClipboard()
        XCTAssertFalse(backup.isEmpty, "Backup should not be empty")
        
        // Clear clipboard
        clipboardManager.clearClipboard()
        XCTAssertFalse(clipboardManager.hasText(), "Clipboard should be empty after clearing")
        
        // Restore clipboard
        let restoreResult = clipboardManager.restoreClipboard(from: backup)
        XCTAssertTrue(restoreResult, "Restoring clipboard should succeed")
        
        // Verify text was restored
        XCTAssertTrue(clipboardManager.hasText(), "Clipboard should have text after restoring")
        XCTAssertEqual(clipboardManager.getTextFromClipboard(), testText, "Restored text should match original")
    }
    
    /// Test hasImage when clipboard has no image
    func testHasImageWhenEmpty() {
        // Clear clipboard
        clipboardManager.clearClipboard()
        
        // Verify no image
        XCTAssertFalse(clipboardManager.hasImage(), "Empty clipboard should not have an image")
    }
    
    /// Test hasImage and getImageFromClipboard
    func testHasImageAndGetImage() {
        // Note: This test is more challenging because we need to put an image on the clipboard
        // In a real test, we might use a small test image or mock the pasteboard
        
        // For now, we'll just test the negative case (no image)
        XCTAssertFalse(clipboardManager.hasImage(), "Clipboard should not have an image")
        XCTAssertNil(clipboardManager.getImageFromClipboard(), "getImageFromClipboard should return nil")
    }
}