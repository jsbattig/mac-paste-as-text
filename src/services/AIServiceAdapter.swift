import Foundation
import AppKit

/// Protocol defining the common interface for AI service adapters
protocol AIServiceAdapter {
    /// The type of AI service
    var serviceType: AIServiceType { get }
    
    /// Whether the service is properly configured with API keys
    var isConfigured: Bool { get }
    
    /// Configure the service with the provided configuration
    /// - Parameter configuration: The configuration for the service
    /// - Throws: AIServiceError if configuration fails
    func configure(with configuration: AIServiceConfiguration) throws
    
    /// Extract text from an image using the AI service
    /// - Parameter image: The image to extract text from
    /// - Returns: The extracted text
    /// - Throws: AIServiceError if text extraction fails
    func extractTextFromImage(_ image: NSImage) async throws -> String
}

/// Enum representing the different types of AI services
enum AIServiceType: String, CaseIterable {
    case gemini
    case openAI
    case anthropic
    
    /// Display name for the service
    var displayName: String {
        switch self {
        case .gemini: return "Google Gemini"
        case .openAI: return "OpenAI"
        case .anthropic: return "Anthropic Claude"
        }
    }
}

/// Configuration for an AI service
struct AIServiceConfiguration {
    /// The API key for the service
    let apiKey: String
    
    /// Optional custom endpoint URL
    let endpoint: URL?
    
    /// Additional service-specific parameters
    let additionalParameters: [String: Any]
    
    /// Initialize with required parameters
    /// - Parameters:
    ///   - apiKey: The API key for the service
    ///   - endpoint: Optional custom endpoint URL (nil for default)
    ///   - additionalParameters: Additional service-specific parameters
    init(apiKey: String, endpoint: URL? = nil, additionalParameters: [String: Any] = [:]) {
        self.apiKey = apiKey
        self.endpoint = endpoint
        self.additionalParameters = additionalParameters
    }
}

/// Errors that can occur when using AI services
enum AIServiceError: Error {
    /// Service is not configured with API keys
    case notConfigured
    
    /// Invalid image format
    case invalidImageFormat
    
    /// Error from the API
    case apiError(String)
    
    /// Error parsing the API response
    case parsingError(String)
    
    /// Rate limit exceeded
    case rateLimitExceeded
    
    /// Network error
    case networkError(Error)
    
    /// User-friendly error description
    var localizedDescription: String {
        switch self {
        case .notConfigured:
            return "AI service is not configured. Please add your API key in settings."
        case .invalidImageFormat:
            return "Invalid image format. Please try a different image."
        case .apiError(let message):
            return "API error: \(message)"
        case .parsingError(let message):
            return "Error parsing response: \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}