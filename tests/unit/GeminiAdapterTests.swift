import XCTest
@testable import PasteAsText

/// Unit tests for the GeminiAdapter
class GeminiAdapterTests: XCTestCase {
    /// The adapter to test
    var adapter: GeminiAdapter!
    
    /// Set up before each test
    override func setUp() {
        super.setUp()
        adapter = GeminiAdapter()
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
        let configuration = AIServiceConfiguration(apiKey: "test_api_key")
        try adapter.configure(with: configuration)
        
        // Verify it's configured
        XCTAssertTrue(adapter.isConfigured)
    }
    
    /// Test configure with valid configuration
    func testConfigureWithValidConfiguration() {
        // Create a valid configuration
        let configuration = AIServiceConfiguration(apiKey: "test_api_key")
        
        // Configure the adapter
        XCTAssertNoThrow(try adapter.configure(with: configuration))
        
        // Verify it's configured
        XCTAssertTrue(adapter.isConfigured)
    }
    
    /// Test configure with custom endpoint
    func testConfigureWithCustomEndpoint() throws {
        // Create a configuration with custom endpoint
        let endpoint = URL(string: "https://custom-endpoint.example.com")!
        let configuration = AIServiceConfiguration(apiKey: "test_api_key", endpoint: endpoint)
        
        // Configure the adapter
        try adapter.configure(with: configuration)
        
        // Verify it's configured
        XCTAssertTrue(adapter.isConfigured)
    }
    
    /// Test extractTextFromImage when not configured
    func testExtractTextFromImageWhenNotConfigured() async {
        // Create a test image
        let image = NSImage(named: NSImage.applicationIconName)!
        
        // Try to extract text
        do {
            _ = try await adapter.extractTextFromImage(image)
            XCTFail("Should throw an error when not configured")
        } catch {
            XCTAssertTrue(error is AIServiceError)
            if let serviceError = error as? AIServiceError {
                XCTAssertEqual(serviceError, AIServiceError.notConfigured)
            }
        }
    }
    
    /// Test extractTextFromImage with invalid image
    func testExtractTextFromImageWithInvalidImage() async throws {
        // Configure the adapter
        let configuration = AIServiceConfiguration(apiKey: "test_api_key")
        try adapter.configure(with: configuration)
        
        // Create an invalid image (empty)
        let image = NSImage(size: .zero)
        
        // Try to extract text
        do {
            _ = try await adapter.extractTextFromImage(image)
            XCTFail("Should throw an error with invalid image")
        } catch {
            XCTAssertTrue(error is AIServiceError)
            if let serviceError = error as? AIServiceError {
                XCTAssertEqual(serviceError, AIServiceError.invalidImageFormat)
            }
        }
    }
    
    /// Test extractTextFromImage with mock response
    func testExtractTextFromImageWithMockResponse() async throws {
        // This test would use a mock URLSession to simulate API responses
        // For now, we'll just outline the approach
        
        // 1. Configure the adapter with a mock URLSession
        // 2. Set up the mock to return a predefined response
        // 3. Call extractTextFromImage
        // 4. Verify the result matches the expected text
        
        // Note: Implementing this properly would require dependency injection
        // to allow injecting a mock URLSession into the adapter
    }
    
    /// Test handling of rate limit errors
    func testHandleRateLimitError() async throws {
        // This test would verify that rate limit errors are properly handled
        // Similar to the mock response test, it would require dependency injection
    }
    
    /// Test handling of network errors
    func testHandleNetworkError() async throws {
        // This test would verify that network errors are properly handled
        // Similar to the mock response test, it would require dependency injection
    }
}