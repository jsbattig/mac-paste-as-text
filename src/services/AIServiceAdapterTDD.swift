import Foundation
import AppKit

/// Protocol for AI service adapters
/// Implemented following TDD principles
protocol AIServiceAdapterProtocol {
    /// The type of AI service
    var serviceType: AIServiceTypeTDD { get }
    
    /// Whether the service is configured with valid credentials
    var isConfigured: Bool { get }
    
    /// Configure the adapter with the provided configuration
    /// - Parameter configuration: The configuration for the service
    /// - Throws: AIServiceErrorTDD if configuration fails
    func configure(with configuration: AIServiceConfigurationTDD) throws
    
    /// Extract text from an image using the AI service
    /// - Parameter image: The image to extract text from
    /// - Returns: The extracted text
    /// - Throws: AIServiceErrorTDD if text extraction fails
    func extractTextFromImage(_ image: NSImage) async throws -> String
}

/// Enum representing the different types of AI services
enum AIServiceTypeTDD: String, CaseIterable {
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
struct AIServiceConfigurationTDD {
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
enum AIServiceErrorTDD: Error, Equatable {
    /// Service is not configured with API keys
    case notConfigured
    
    /// Invalid configuration (e.g., empty API key)
    case invalidConfiguration
    
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
    
    /// Equatable implementation
    static func == (lhs: AIServiceErrorTDD, rhs: AIServiceErrorTDD) -> Bool {
        switch (lhs, rhs) {
        case (.notConfigured, .notConfigured),
             (.invalidConfiguration, .invalidConfiguration),
             (.invalidImageFormat, .invalidImageFormat),
             (.rateLimitExceeded, .rateLimitExceeded):
            return true
        case (.apiError(let lhsMessage), .apiError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.parsingError(let lhsMessage), .parsingError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

/// Manager for AI service adapters
class AIServiceManagerTDD {
    /// Shared instance (singleton)
    static let shared = AIServiceManagerTDD()
    
    /// Available service adapters
    private var adapters: [AIServiceTypeTDD: AIServiceAdapterProtocol] = [:]
    
    /// Currently selected service type
    private(set) var selectedServiceType: AIServiceTypeTDD = .gemini
    
    /// Currently selected service adapter
    var selectedAdapter: AIServiceAdapterProtocol? {
        return adapters[selectedServiceType]
    }
    
    /// Private initializer for singleton
    private init() {
        // Register default adapters
        // In a real implementation, we would register actual adapters here
    }
    
    /// Register a service adapter
    /// - Parameter adapter: The adapter to register
    func registerServiceAdapter(_ adapter: AIServiceAdapterProtocol) {
        adapters[adapter.serviceType] = adapter
    }
    
    /// Select a service type
    /// - Parameter serviceType: The service type to select
    /// - Returns: True if the service type was found and selected
    @discardableResult
    func selectServiceType(_ serviceType: AIServiceTypeTDD) -> Bool {
        guard adapters[serviceType] != nil else {
            return false
        }
        
        selectedServiceType = serviceType
        return true
    }
    
    /// Configure the selected adapter
    /// - Parameter configuration: The configuration for the service
    /// - Throws: AIServiceErrorTDD if configuration fails
    func configureSelectedAdapter(with configuration: AIServiceConfigurationTDD) throws {
        guard let adapter = selectedAdapter else {
            throw AIServiceErrorTDD.notConfigured
        }
        
        try adapter.configure(with: configuration)
    }
    
    /// Extract text from an image using the selected adapter
    /// - Parameter image: The image to extract text from
    /// - Returns: The extracted text
    /// - Throws: AIServiceErrorTDD if text extraction fails
    func extractTextFromImage(_ image: NSImage) async throws -> String {
        guard let adapter = selectedAdapter else {
            throw AIServiceErrorTDD.notConfigured
        }
        
        guard adapter.isConfigured else {
            throw AIServiceErrorTDD.notConfigured
        }
        
        return try await adapter.extractTextFromImage(image)
    }
    
    /// Get all available service types
    /// - Returns: Array of available service types
    func getAvailableServiceTypes() -> [AIServiceTypeTDD] {
        return Array(adapters.keys)
    }
    
    /// Check if a service type is available
    /// - Parameter serviceType: The service type to check
    /// - Returns: True if the service type is available
    func isServiceTypeAvailable(_ serviceType: AIServiceTypeTDD) -> Bool {
        return adapters[serviceType] != nil
    }
    
    /// Check if the selected adapter is configured
    /// - Returns: True if the selected adapter is configured
    func isSelectedAdapterConfigured() -> Bool {
        return selectedAdapter?.isConfigured ?? false
    }
}