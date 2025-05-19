import Foundation

/// Value object representing the immutable result of OCR
struct ExtractedText {
    /// The extracted text content
    let content: String
    
    /// The source image ID that the text was extracted from
    let sourceImageId: UUID
    
    /// The AI service used for extraction
    let serviceType: AIServiceType
    
    /// The confidence level of the extraction (0.0 to 1.0) if available
    let confidence: Double?
    
    /// The language of the extracted text if detected
    let detectedLanguage: String?
    
    /// The timestamp when the extraction was performed
    let extractedAt: Date
    
    /// Initialize with required parameters
    /// - Parameters:
    ///   - content: The extracted text content
    ///   - sourceImageId: The source image ID
    ///   - serviceType: The AI service used
    ///   - confidence: Optional confidence level
    ///   - detectedLanguage: Optional detected language
    ///   - extractedAt: Extraction timestamp (defaults to current time)
    init(
        content: String,
        sourceImageId: UUID,
        serviceType: AIServiceType,
        confidence: Double? = nil,
        detectedLanguage: String? = nil,
        extractedAt: Date = Date()
    ) {
        self.content = content
        self.sourceImageId = sourceImageId
        self.serviceType = serviceType
        self.confidence = confidence
        self.detectedLanguage = detectedLanguage
        self.extractedAt = extractedAt
    }
    
    /// Get the word count of the extracted text
    /// - Returns: Number of words
    func wordCount() -> Int {
        let words = content.split(separator: " ")
        return words.count
    }
    
    /// Get the character count of the extracted text
    /// - Returns: Number of characters
    func characterCount() -> Int {
        return content.count
    }
    
    /// Check if the extracted text is empty
    /// - Returns: True if the text is empty or contains only whitespace
    func isEmpty() -> Bool {
        return content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Get a summary of the extracted text (first few words)
    /// - Parameter maxWords: Maximum number of words to include
    /// - Returns: Summary string
    func summary(maxWords: Int = 10) -> String {
        let words = content.split(separator: " ")
        if words.count <= maxWords {
            return content
        }
        
        let summary = words.prefix(maxWords).joined(separator: " ")
        return summary + "..."
    }
    
    /// Create a new ExtractedText with the same properties but different content
    /// - Parameter newContent: The new content
    /// - Returns: A new ExtractedText instance
    func withContent(_ newContent: String) -> ExtractedText {
        return ExtractedText(
            content: newContent,
            sourceImageId: sourceImageId,
            serviceType: serviceType,
            confidence: confidence,
            detectedLanguage: detectedLanguage,
            extractedAt: extractedAt
        )
    }
}

/// Extension to add Equatable conformance
extension ExtractedText: Equatable {
    static func == (lhs: ExtractedText, rhs: ExtractedText) -> Bool {
        return lhs.content == rhs.content &&
               lhs.sourceImageId == rhs.sourceImageId &&
               lhs.serviceType == rhs.serviceType &&
               lhs.confidence == rhs.confidence &&
               lhs.detectedLanguage == rhs.detectedLanguage &&
               lhs.extractedAt == rhs.extractedAt
    }
}

/// Extension to add Hashable conformance
extension ExtractedText: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
        hasher.combine(sourceImageId)
        hasher.combine(serviceType)
        hasher.combine(confidence)
        hasher.combine(detectedLanguage)
        hasher.combine(extractedAt)
    }
}