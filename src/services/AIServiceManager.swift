import Foundation
import AppKit

/// Manager for AI service adapters
class AIServiceManager {
    /// Shared instance (singleton)
    static let shared = AIServiceManager()
    
    /// Dictionary of available service adapters
    private var serviceAdapters: [AIServiceType: AIServiceAdapter] = [:]
    
    /// Private initializer for singleton
    private init() {
        // Register available service adapters
        registerServiceAdapter(GeminiAdapter())
        
        // Configure adapters with saved API keys
        configureAdapters()
    }
    
    /// Register a service adapter
    /// - Parameter adapter: The adapter to register
    func registerServiceAdapter(_ adapter: AIServiceAdapter) {
        serviceAdapters[adapter.serviceType] = adapter
    }
    
    /// Configure all adapters with saved API keys
    private func configureAdapters() {
        for (serviceType, adapter) in serviceAdapters {
            do {
                if let apiKey = try KeychainManager.shared.getAPIKey(for: serviceType) {
                    let configuration = AIServiceConfiguration(apiKey: apiKey)
                    try adapter.configure(with: configuration)
                }
            } catch {
                print("Failed to configure \(serviceType.displayName): \(error.localizedDescription)")
            }
        }
    }
    
    /// Get the adapter for the specified service type
    /// - Parameter serviceType: The service type
    /// - Returns: The adapter if available
    /// - Throws: AIServiceError if the adapter is not available
    func getAdapter(for serviceType: AIServiceType) throws -> AIServiceAdapter {
        guard let adapter = serviceAdapters[serviceType] else {
            throw AIServiceError.apiError("Service adapter not available for \(serviceType.displayName)")
        }
        
        return adapter
    }
    
    /// Get the adapter for the currently selected service
    /// - Returns: The adapter for the selected service
    /// - Throws: AIServiceError if the adapter is not available or not configured
    func getSelectedAdapter() throws -> AIServiceAdapter {
        let selectedService = PreferencesManager.shared.selectedAIService
        let adapter = try getAdapter(for: selectedService)
        
        guard adapter.isConfigured else {
            throw AIServiceError.notConfigured
        }
        
        return adapter
    }
    
    /// Extract text from an image using the selected AI service
    /// - Parameter image: The image to extract text from
    /// - Returns: The extracted text
    /// - Throws: AIServiceError if text extraction fails
    func extractTextFromImage(_ image: NSImage) async throws -> String {
        let adapter = try getSelectedAdapter()
        
        // Get the maximum number of retries from preferences
        let maxRetries = PreferencesManager.shared.maxRetries
        
        // Try to extract text with retries
        var lastError: Error? = nil
        for attempt in 0...maxRetries {
            do {
                return try await adapter.extractTextFromImage(image)
            } catch AIServiceError.rateLimitExceeded where attempt < maxRetries {
                // Wait before retrying if rate limited
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 1_000_000_000))
                lastError = AIServiceError.rateLimitExceeded
                continue
            } catch {
                lastError = error
                break
            }
        }
        
        // If we get here, all attempts failed
        throw lastError ?? AIServiceError.apiError("Failed to extract text after \(maxRetries) attempts")
    }
    
    /// Extract text from an image and create an ExtractedText value object
    /// - Parameter imageContent: The image content
    /// - Returns: An ExtractedText value object
    /// - Throws: AIServiceError if text extraction fails
    func extractText(from imageContent: ImageContent) async throws -> ExtractedText {
        let selectedService = PreferencesManager.shared.selectedAIService
        let text = try await extractTextFromImage(imageContent.getImage())
        
        return ExtractedText(
            content: text,
            sourceImageId: imageContent.id,
            serviceType: selectedService
        )
    }
    
    /// Configure a service with an API key
    /// - Parameters:
    ///   - serviceType: The service type
    ///   - apiKey: The API key
    /// - Throws: Error if configuration fails
    func configureService(_ serviceType: AIServiceType, withAPIKey apiKey: String) throws {
        // Save API key to Keychain
        try KeychainManager.shared.saveAPIKey(apiKey, for: serviceType)
        
        // Configure the adapter
        guard let adapter = serviceAdapters[serviceType] else {
            throw AIServiceError.apiError("Service adapter not available for \(serviceType.displayName)")
        }
        
        let configuration = AIServiceConfiguration(apiKey: apiKey)
        try adapter.configure(with: configuration)
    }
    
    /// Get all available service types
    /// - Returns: Array of available service types
    func getAvailableServiceTypes() -> [AIServiceType] {
        return Array(serviceAdapters.keys)
    }
    
    /// Check if a service is configured
    /// - Parameter serviceType: The service type
    /// - Returns: True if the service is configured
    func isServiceConfigured(_ serviceType: AIServiceType) -> Bool {
        guard let adapter = serviceAdapters[serviceType] else {
            return false
        }
        
        return adapter.isConfigured
    }
}