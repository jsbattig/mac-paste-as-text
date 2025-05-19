import Foundation

/// Value object representing extracted text from an image
/// Implemented following TDD principles
struct ExtractedTextTDD: Equatable, Hashable {
    /// The extracted text
    let text: String
    
    /// Confidence score (0.0 to 1.0)
    let confidence: Double?
    
    /// Detected language code (e.g., "en", "fr")
    let language: String?
    
    /// Additional metadata
    let metadata: [String: Any]
    
    /// Initialize with text
    /// - Parameters:
    ///   - text: The extracted text
    ///   - confidence: Optional confidence score (0.0 to 1.0)
    ///   - language: Optional detected language code
    ///   - metadata: Optional additional metadata
    init(text: String, confidence: Double? = nil, language: String? = nil, metadata: [String: Any] = [:]) {
        self.text = text
        self.confidence = confidence
        self.language = language
        self.metadata = metadata
    }
    
    /// Get the number of words in the text
    /// - Returns: Word count
    func getWordCount() -> Int {
        let words = text.split(separator: " ")
        return words.count
    }
    
    /// Get the number of characters in the text
    /// - Returns: Character count
    func getCharacterCount() -> Int {
        return text.count
    }
    
    /// Get the lines of text
    /// - Returns: Array of lines
    func getLines() -> [String] {
        return text.split(separator: "\n").map(String.init)
    }
    
    /// Get a metadata value
    /// - Parameter key: The metadata key
    /// - Returns: The metadata value, or nil if not found
    func getMetadataValue(key: String) -> Any? {
        return metadata[key]
    }
    
    /// Create a new ExtractedText with trimmed whitespace
    /// - Returns: A new ExtractedText with trimmed text
    func trimmed() -> ExtractedTextTDD {
        return ExtractedTextTDD(
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            confidence: confidence,
            language: language,
            metadata: metadata
        )
    }
    
    /// Create a new ExtractedText with lowercase text
    /// - Returns: A new ExtractedText with lowercase text
    func lowercased() -> ExtractedTextTDD {
        return ExtractedTextTDD(
            text: text.lowercased(),
            confidence: confidence,
            language: language,
            metadata: metadata
        )
    }
    
    /// Create a new ExtractedText with uppercase text
    /// - Returns: A new ExtractedText with uppercase text
    func uppercased() -> ExtractedTextTDD {
        return ExtractedTextTDD(
            text: text.uppercased(),
            confidence: confidence,
            language: language,
            metadata: metadata
        )
    }
    
    /// Check if the text contains a substring
    /// - Parameter substring: The substring to check for
    /// - Returns: True if the text contains the substring
    func contains(_ substring: String) -> Bool {
        return text.contains(substring)
    }
    
    /// Check if the text matches a regular expression
    /// - Parameter regex: The regular expression pattern
    /// - Returns: True if the text matches the pattern
    func matches(regex: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: regex) else {
            return false
        }
        
        let range = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, range: range) != nil
    }
    
    /// Split the text into chunks of a maximum length
    /// - Parameter maxLength: The maximum length of each chunk
    /// - Returns: Array of ExtractedText objects, each with a chunk of the original text
    func splitIntoChunks(maxLength: Int) -> [ExtractedTextTDD] {
        guard maxLength > 0 else {
            return [self]
        }
        
        var chunks: [ExtractedTextTDD] = []
        var currentIndex = text.startIndex
        
        while currentIndex < text.endIndex {
            let endIndex = text.index(currentIndex, offsetBy: maxLength, limitedBy: text.endIndex) ?? text.endIndex
            let chunk = String(text[currentIndex..<endIndex])
            
            chunks.append(ExtractedTextTDD(
                text: chunk,
                confidence: confidence,
                language: language,
                metadata: metadata
            ))
            
            currentIndex = endIndex
        }
        
        return chunks
    }
    
    /// Equality operator
    static func == (lhs: ExtractedTextTDD, rhs: ExtractedTextTDD) -> Bool {
        return lhs.text == rhs.text &&
               lhs.confidence == rhs.confidence &&
               lhs.language == rhs.language
    }
    
    /// Hash function
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        if let confidence = confidence {
            hasher.combine(confidence)
        }
        if let language = language {
            hasher.combine(language)
        }
    }
    
    /// Convert to a dictionary representation
    /// - Returns: Dictionary representation
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "text": text
        ]
        
        if let confidence = confidence {
            dict["confidence"] = confidence
        }
        
        if let language = language {
            dict["language"] = language
        }
        
        if !metadata.isEmpty {
            dict["metadata"] = metadata
        }
        
        return dict
    }
    
    /// Create from a dictionary representation
    /// - Parameter dict: Dictionary representation
    /// - Returns: ExtractedText instance, or nil if invalid
    static func fromDictionary(_ dict: [String: Any]) -> ExtractedTextTDD? {
        guard let text = dict["text"] as? String else {
            return nil
        }
        
        let confidence = dict["confidence"] as? Double
        let language = dict["language"] as? String
        let metadata = dict["metadata"] as? [String: Any] ?? [:]
        
        return ExtractedTextTDD(
            text: text,
            confidence: confidence,
            language: language,
            metadata: metadata
        )
    }
}