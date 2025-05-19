import Foundation
import AppKit

/// Adapter for the Google Gemini API
class GeminiAdapter: AIServiceAdapter {
    /// The service type
    var serviceType: AIServiceType { return .gemini }
    
    /// API key for Gemini
    private var apiKey: String?
    
    /// API endpoint URL
    private var endpoint: URL?
    
    /// Whether the service is configured with an API key
    var isConfigured: Bool {
        return apiKey != nil
    }
    
    /// Initialize a new Gemini adapter
    init() {
        // Default initialization with no API key
    }
    
    /// Configure the adapter with the provided configuration
    /// - Parameter configuration: The configuration for the service
    /// - Throws: AIServiceError if configuration fails
    func configure(with configuration: AIServiceConfiguration) throws {
        self.apiKey = configuration.apiKey
        self.endpoint = configuration.endpoint ?? URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent")
        
        guard self.endpoint != nil else {
            throw AIServiceError.apiError("Invalid endpoint URL")
        }
    }
    
    /// Extract text from an image using the Gemini API
    /// - Parameter image: The image to extract text from
    /// - Returns: The extracted text
    /// - Throws: AIServiceError if text extraction fails
    func extractTextFromImage(_ image: NSImage) async throws -> String {
        guard let apiKey = apiKey, let endpoint = endpoint else {
            throw AIServiceError.notConfigured
        }
        
        guard let imageData = image.tiffRepresentation else {
            throw AIServiceError.invalidImageFormat
        }
        
        // Convert to JPEG for better compatibility with the API
        let bitmap = NSBitmapImageRep(data: imageData)
        guard let jpegData = bitmap?.representation(using: .jpeg, properties: [:]) else {
            throw AIServiceError.invalidImageFormat
        }
        
        let base64Image = jpegData.base64EncodedString()
        
        // Create the request
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add API key as query parameter for Gemini
        let urlWithKey = endpoint.absoluteString + "?key=\(apiKey)"
        request.url = URL(string: urlWithKey)
        
        // Create the request body
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": "Extract all visible text from this image"],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ]
        ]
        
        // Serialize the request body to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        // Send the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check for HTTP errors
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIServiceError.networkError(NSError(domain: "GeminiAdapter", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
            
            // Check for rate limiting
            if httpResponse.statusCode == 429 {
                throw AIServiceError.rateLimitExceeded
            }
            
            // Check for other HTTP errors
            guard 200...299 ~= httpResponse.statusCode else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw AIServiceError.apiError("HTTP error \(httpResponse.statusCode): \(errorMessage)")
            }
            
            // Parse the response
            let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            // Extract the text from the response
            guard let candidates = jsonResponse?["candidates"] as? [[String: Any]],
                  let candidate = candidates.first,
                  let content = candidate["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let part = parts.first,
                  let text = part["text"] as? String else {
                throw AIServiceError.parsingError("Failed to parse Gemini API response")
            }
            
            return text
        } catch let error as AIServiceError {
            throw error
        } catch {
            throw AIServiceError.networkError(error)
        }
    }
}