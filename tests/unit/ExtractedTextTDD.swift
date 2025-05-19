import XCTest
@testable import PasteAsText

/// Unit tests for the ExtractedText value object following TDD approach
class ExtractedTextTDD: XCTestCase {
    
    /// Test initializing with text
    func testInitWithText() {
        // Create an ExtractedText with text
        let text = "This is extracted text"
        let extractedText = ExtractedTextTDD_Implementation(text: text)
        
        // Verify the text was set
        XCTAssertEqual(extractedText.text, text)
        XCTAssertNil(extractedText.confidence)
        XCTAssertNil(extractedText.language)
        XCTAssertEqual(extractedText.metadata.count, 0)
    }
    
    /// Test initializing with text, confidence, and language
    func testInitWithTextConfidenceAndLanguage() {
        // Create an ExtractedText with text, confidence, and language
        let text = "This is extracted text"
        let confidence = 0.95
        let language = "en"
        let extractedText = ExtractedTextTDD_Implementation(text: text, confidence: confidence, language: language)
        
        // Verify the properties were set
        XCTAssertEqual(extractedText.text, text)
        XCTAssertEqual(extractedText.confidence, confidence)
        XCTAssertEqual(extractedText.language, language)
        XCTAssertEqual(extractedText.metadata.count, 0)
    }
    
    /// Test initializing with text, confidence, language, and metadata
    func testInitWithTextConfidenceLanguageAndMetadata() {
        // Create an ExtractedText with text, confidence, language, and metadata
        let text = "This is extracted text"
        let confidence = 0.95
        let language = "en"
        let metadata: [String: Any] = [
            "source": "Gemini",
            "timestamp": Date(),
            "processingTime": 0.5
        ]
        let extractedText = ExtractedTextTDD_Implementation(text: text, confidence: confidence, language: language, metadata: metadata)
        
        // Verify the properties were set
        XCTAssertEqual(extractedText.text, text)
        XCTAssertEqual(extractedText.confidence, confidence)
        XCTAssertEqual(extractedText.language, language)
        XCTAssertEqual(extractedText.metadata["source"] as? String, "Gemini")
        XCTAssertNotNil(extractedText.metadata["timestamp"])
        XCTAssertEqual(extractedText.metadata["processingTime"] as? Double, 0.5)
    }
    
    /// Test getting word count
    func testGetWordCount() {
        // Create an ExtractedText with text
        let text = "This is extracted text with multiple words"
        let extractedText = ExtractedTextTDD_Implementation(text: text)
        
        // Verify the word count
        XCTAssertEqual(extractedText.getWordCount(), 7)
    }
    
    /// Test getting character count
    func testGetCharacterCount() {
        // Create an ExtractedText with text
        let text = "This is extracted text"
        let extractedText = ExtractedTextTDD_Implementation(text: text)
        
        // Verify the character count
        XCTAssertEqual(extractedText.getCharacterCount(), 21)
    }
    
    /// Test getting lines
    func testGetLines() {
        // Create an ExtractedText with multi-line text
        let text = "Line 1\nLine 2\nLine 3"
        let extractedText = ExtractedTextTDD_Implementation(text: text)
        
        // Verify the lines
        let lines = extractedText.getLines()
        XCTAssertEqual(lines.count, 3)
        XCTAssertEqual(lines[0], "Line 1")
        XCTAssertEqual(lines[1], "Line 2")
        XCTAssertEqual(lines[2], "Line 3")
    }
    
    /// Test getting metadata value
    func testGetMetadataValue() {
        // Create metadata
        let metadata: [String: Any] = [
            "source": "Gemini",
            "timestamp": Date(),
            "processingTime": 0.5
        ]
        
        // Create an ExtractedText with metadata
        let extractedText = ExtractedTextTDD_Implementation(text: "Text", metadata: metadata)
        
        // Get metadata values
        let source = extractedText.getMetadataValue(key: "source") as? String
        let processingTime = extractedText.getMetadataValue(key: "processingTime") as? Double
        let nonExistent = extractedText.getMetadataValue(key: "nonExistent")
        
        // Verify the values
        XCTAssertEqual(source, "Gemini")
        XCTAssertEqual(processingTime, 0.5)
        XCTAssertNil(nonExistent)
    }
    
    /// Test equality
    func testEquality() {
        // Create two identical ExtractedText objects
        let text = "This is extracted text"
        let confidence = 0.95
        let language = "en"
        let metadata: [String: Any] = ["source": "Gemini"]
        
        let extractedText1 = ExtractedTextTDD_Implementation(text: text, confidence: confidence, language: language, metadata: metadata)
        let extractedText2 = ExtractedTextTDD_Implementation(text: text, confidence: confidence, language: language, metadata: metadata)
        
        // Verify they are equal
        XCTAssertEqual(extractedText1, extractedText2)
    }
    
    /// Test inequality with different text
    func testInequalityWithDifferentText() {
        // Create two ExtractedText objects with different text
        let extractedText1 = ExtractedTextTDD_Implementation(text: "Text 1")
        let extractedText2 = ExtractedTextTDD_Implementation(text: "Text 2")
        
        // Verify they are not equal
        XCTAssertNotEqual(extractedText1, extractedText2)
    }
    
    /// Test inequality with different confidence
    func testInequalityWithDifferentConfidence() {
        // Create two ExtractedText objects with different confidence
        let extractedText1 = ExtractedTextTDD_Implementation(text: "Text", confidence: 0.9)
        let extractedText2 = ExtractedTextTDD_Implementation(text: "Text", confidence: 0.8)
        
        // Verify they are not equal
        XCTAssertNotEqual(extractedText1, extractedText2)
    }
    
    /// Test inequality with different language
    func testInequalityWithDifferentLanguage() {
        // Create two ExtractedText objects with different language
        let extractedText1 = ExtractedTextTDD_Implementation(text: "Text", language: "en")
        let extractedText2 = ExtractedTextTDD_Implementation(text: "Text", language: "fr")
        
        // Verify they are not equal
        XCTAssertNotEqual(extractedText1, extractedText2)
    }
}

// Minimal implementation to make the tests pass
struct ExtractedTextTDD_Implementation: Equatable {
    let text: String
    let confidence: Double?
    let language: String?
    let metadata: [String: Any]
    
    init(text: String, confidence: Double? = nil, language: String? = nil, metadata: [String: Any] = [:]) {
        self.text = text
        self.confidence = confidence
        self.language = language
        self.metadata = metadata
    }
    
    func getWordCount() -> Int {
        let words = text.split(separator: " ")
        return words.count
    }
    
    func getCharacterCount() -> Int {
        return text.count
    }
    
    func getLines() -> [String] {
        return text.split(separator: "\n").map(String.init)
    }
    
    func getMetadataValue(key: String) -> Any? {
        return metadata[key]
    }
    
    static func == (lhs: ExtractedTextTDD_Implementation, rhs: ExtractedTextTDD_Implementation) -> Bool {
        return lhs.text == rhs.text &&
               lhs.confidence == rhs.confidence &&
               lhs.language == rhs.language
    }
}