import XCTest
@testable import PasteAsText

/// Unit tests for the GeminiAdapter following TDD approach
class GeminiAdapterTDD: XCTestCase {
    
    /// The adapter to test
    var adapter: GeminiAdapterTDD_Implementation!
    
    /// Set up before each test
    override func setUp() {
        super.setUp()
        adapter = GeminiAdapterTDD_Implementation()
    }
    
    /// Tear down after each test
    override func tearDown() {
        adapter = nil
        super.tearDown()
    }
    
    /// Test the service type
    func testServiceType() {
        XCTAssertEqual(adapter.serviceType, .gemini)
    }
    
    /// Test isConfigured when not configured
    func testIsConfiguredWhenNotConfigured() {
        XCTAssertFalse(adapter.isConfigured)
    }
    
    /// Test isConfigured when configured
    func testIsConfiguredWhenConfigured() throws {
        // Configure the adapter
        let configuration = AIServiceConfigurationTDD(apiKey: "test_api_key")
        try adapter.configure(with: configuration)
        
        // Verify it's configured
        XCTAssertTrue(adapter.isConfigured)
    }
    
    /// Test configure with valid configuration
    func testConfigureWithValidConfiguration() {
        // Create a valid configuration
        let configuration = AIServiceConfigurationTDD(apiKey: "test_api_key")
        
        // Configure the adapter
        XCTAssertNoThrow(try adapter.configure(with: configuration))
        
        // Verify it's configured
        XCTAssertTrue(adapter.isConfigured)
    }
    
    /// Test configure with invalid configuration (empty API key)
    func testConfigureWithInvalidConfiguration() {
        // Create an invalid configuration with empty API key
        let configuration = AIServiceConfigurationTDD(apiKey: "")
        
        // Configure the adapter - should throw an error
        XCTAssertThrowsError(try adapter.configure(with: configuration)) { error in
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.invalidConfiguration)
        }
        
        // Verify it's not configured
        XCTAssertFalse(adapter.isConfigured)
    }
    
    /// Test extractTextFromImage when not configured
    func testExtractTextFromImageWhenNotConfigured() async {
        // Create a test image
        let image = NSImage()
        
        // Try to extract text
        do {
            _ = try await adapter.extractTextFromImage(image)
            XCTFail("Should throw an error when not configured")
        } catch {
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.notConfigured)
        }
    }
    
    /// Test extractTextFromImage with mock successful response
    func testExtractTextFromImageWithMockSuccess() async throws {
        // Configure the adapter
        let configuration = AIServiceConfigurationTDD(apiKey: "test_api_key")
        try adapter.configure(with: configuration)
        
        // Set up mock response
        adapter.mockResponse = "Extracted text from image"
        
        // Extract text
        let extractedText = try await adapter.extractTextFromImage(NSImage())
        
        // Verify the result
        XCTAssertEqual(extractedText, "Extracted text from image")
    }
    
    /// Test extractTextFromImage with mock error response
    func testExtractTextFromImageWithMockError() async throws {
        // Configure the adapter
        let configuration = AIServiceConfigurationTDD(apiKey: "test_api_key")
        try adapter.configure(with: configuration)
        
        // Set up mock error
        adapter.mockError = AIServiceErrorTDD.apiError("Mock API error")
        
        // Try to extract text
        do {
            _ = try await adapter.extractTextFromImage(NSImage())
            XCTFail("Should throw the mock error")
        } catch {
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.apiError("Mock API error"))
        }
    }
}

// Minimal implementation to make the tests pass
enum AIServiceTypeTDD: String {
    case gemini
    case openAI
    case anthropic
}

struct AIServiceConfigurationTDD {
    let apiKey: String
    let endpoint: URL?
    
    init(apiKey: String, endpoint: URL? = nil) {
        self.apiKey = apiKey
        self.endpoint = endpoint
    }
}

enum AIServiceErrorTDD: Error, Equatable {
    case notConfigured
    case invalidConfiguration
    case apiError(String)
    
    static func == (lhs: AIServiceErrorTDD, rhs: AIServiceErrorTDD) -> Bool {
        switch (lhs, rhs) {
        case (.notConfigured, .notConfigured):
            return true
        case (.invalidConfiguration, .invalidConfiguration):
            return true
        case (.apiError(let lhsMessage), .apiError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

class GeminiAdapterTDD_Implementation {
    var serviceType: AIServiceTypeTDD { return .gemini }
    private var apiKey: String?
    
    var isConfigured: Bool {
        return apiKey != nil && !apiKey!.isEmpty
    }
    
    // For testing purposes
    var mockResponse: String?
    var mockError: AIServiceErrorTDD?
    
    func configure(with configuration: AIServiceConfigurationTDD) throws {
        if configuration.apiKey.isEmpty {
            throw AIServiceErrorTDD.invalidConfiguration
        }
        self.apiKey = configuration.apiKey
    }
    
    func extractTextFromImage(_ image: NSImage) async throws -> String {
        guard isConfigured else {
            throw AIServiceErrorTDD.notConfigured
        }
        
        // Return mock error if set
        if let mockError = mockError {
            throw mockError
        }
        
        // Return mock response if set
        if let mockResponse = mockResponse {
            return mockResponse
        }
        
        // Default response
        return "Default extracted text"
    }
}