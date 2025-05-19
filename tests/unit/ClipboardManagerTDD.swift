import XCTest
@testable import PasteAsText

/// Unit tests for the ClipboardManager following TDD approach
class ClipboardManagerTDD: XCTestCase {
    
    /// Test that we can write and read text from the clipboard
    func testWriteAndReadText() {
        // Arrange
        let testText = "Hello, TDD World!"
        let clipboardManager = ClipboardManagerTDD_Implementation()
        
        // Act
        let writeResult = clipboardManager.writeTextToClipboard(testText)
        let readText = clipboardManager.getTextFromClipboard()
        
        // Assert
        XCTAssertTrue(writeResult, "Writing text to clipboard should succeed")
        XCTAssertEqual(readText, testText, "Read text should match written text")
    }
    
    /// Test that we can clear the clipboard
    func testClearClipboard() {
        // Arrange
        let testText = "Text to be cleared"
        let clipboardManager = ClipboardManagerTDD_Implementation()
        
        // Act - First write text, then clear
        clipboardManager.writeTextToClipboard(testText)
        clipboardManager.clearClipboard()
        
        // Assert
        XCTAssertNil(clipboardManager.getTextFromClipboard(), "Clipboard should be empty after clearing")
    }
    
    /// Test that we can detect if the clipboard has text
    func testHasText() {
        // Arrange
        let clipboardManager = ClipboardManagerTDD_Implementation()
        
        // Act - Clear first to ensure empty clipboard, then write
        clipboardManager.clearClipboard()
        let hasTextBefore = clipboardManager.hasText()
        
        clipboardManager.writeTextToClipboard("Some text")
        let hasTextAfter = clipboardManager.hasText()
        
        // Assert
        XCTAssertFalse(hasTextBefore, "Clipboard should not have text after clearing")
        XCTAssertTrue(hasTextAfter, "Clipboard should have text after writing")
    }
    
    /// Test that we can detect clipboard changes
    func testClipboardChangeCount() {
        // Arrange
        let clipboardManager = ClipboardManagerTDD_Implementation()
        
        // Act
        let initialCount = clipboardManager.getChangeCount()
        clipboardManager.writeTextToClipboard("Change text")
        let newCount = clipboardManager.getChangeCount()
        
        // Assert
        XCTAssertGreaterThan(newCount, initialCount, "Change count should increase after writing")
        XCTAssertTrue(clipboardManager.hasClipboardChanged(since: initialCount), "Should detect clipboard change")
        XCTAssertFalse(clipboardManager.hasClipboardChanged(since: newCount), "Should not detect change when count matches")
    }
}

// This is the minimal implementation to make the tests pass
// In TDD, we would implement this after writing the failing tests
class ClipboardManagerTDD_Implementation {
    private var clipboardContent: String?
    private var changeCount = 0
    
    func writeTextToClipboard(_ text: String) -> Bool {
        clipboardContent = text
        changeCount += 1
        return true
    }
    
    func getTextFromClipboard() -> String? {
        return clipboardContent
    }
    
    func clearClipboard() {
        clipboardContent = nil
        changeCount += 1
    }
    
    func hasText() -> Bool {
        return clipboardContent != nil
    }
    
    func getChangeCount() -> Int {
        return changeCount
    }
    
    func hasClipboardChanged(since count: Int) -> Bool {
        return changeCount != count
    }
}