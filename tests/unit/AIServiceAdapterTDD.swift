import XCTest
@testable import PasteAsText

/// Unit tests for the AIServiceAdapter protocol following TDD approach
class AIServiceAdapterTDD: XCTestCase {
    
    /// Test adapter for testing the protocol
    class MockAIServiceAdapter: AIServiceAdapterProtocol {
        var serviceType: AIServiceTypeTDD = .mock
        var isConfigured: Bool = false
        var configureWasCalled = false
        var extractTextWasCalled = false
        var mockResponse: String?
        var mockError: AIServiceErrorTDD?
        
        func configure(with configuration: AIServiceConfigurationTDD) throws {
            configureWasCalled = true
            
            if configuration.apiKey.isEmpty {
                throw AIServiceErrorTDD.invalidConfiguration
            }
            
            isConfigured = true
        }
        
        func extractTextFromImage(_ image: NSImage) async throws -> String {
            extractTextWasCalled = true
            
            if !isConfigured {
                throw AIServiceErrorTDD.notConfigured
            }
            
            if let mockError = mockError {
                throw mockError
            }
            
            return mockResponse ?? "Mock extracted text"
        }
    }
    
    /// The mock adapter to test
    var mockAdapter: MockAIServiceAdapter!
    
    /// Set up before each test
    override func setUp() {
        super.setUp()
        mockAdapter = MockAIServiceAdapter()
    }
    
    /// Tear down after each test
    override func tearDown() {
        mockAdapter = nil
        super.tearDown()
    }
    
    /// Test that the adapter is not configured by default
    func testIsNotConfiguredByDefault() {
        XCTAssertFalse(mockAdapter.isConfigured)
    }
    
    /// Test that configure is called with valid configuration
    func testConfigureWithValidConfiguration() throws {
        // Create a valid configuration
        let configuration = AIServiceConfigurationTDD(apiKey: "test_api_key")
        
        // Configure the adapter
        try mockAdapter.configure(with: configuration)
        
        // Verify configure was called and adapter is configured
        XCTAssertTrue(mockAdapter.configureWasCalled)
        XCTAssertTrue(mockAdapter.isConfigured)
    }
    
    /// Test that configure throws with invalid configuration
    func testConfigureWithInvalidConfiguration() {
        // Create an invalid configuration with empty API key
        let configuration = AIServiceConfigurationTDD(apiKey: "")
        
        // Configure the adapter - should throw an error
        XCTAssertThrowsError(try mockAdapter.configure(with: configuration)) { error in
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.invalidConfiguration)
        }
        
        // Verify configure was called but adapter is not configured
        XCTAssertTrue(mockAdapter.configureWasCalled)
        XCTAssertFalse(mockAdapter.isConfigured)
    }
    
    /// Test that extractTextFromImage throws when not configured
    func testExtractTextFromImageWhenNotConfigured() async {
        // Create a test image
        let image = NSImage()
        
        // Try to extract text
        do {
            _ = try await mockAdapter.extractTextFromImage(image)
            XCTFail("Should throw an error when not configured")
        } catch {
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.notConfigured)
        }
        
        // Verify extractTextFromImage was called
        XCTAssertTrue(mockAdapter.extractTextWasCalled)
    }
    
    /// Test that extractTextFromImage returns mock response when configured
    func testExtractTextFromImageWhenConfigured() async throws {
        // Configure the adapter
        let configuration = AIServiceConfigurationTDD(apiKey: "test_api_key")
        try mockAdapter.configure(with: configuration)
        
        // Set up mock response
        mockAdapter.mockResponse = "Test extracted text"
        
        // Extract text
        let extractedText = try await mockAdapter.extractTextFromImage(NSImage())
        
        // Verify extractTextFromImage was called and returned the mock response
        XCTAssertTrue(mockAdapter.extractTextWasCalled)
        XCTAssertEqual(extractedText, "Test extracted text")
    }
    
    /// Test that extractTextFromImage throws mock error
    func testExtractTextFromImageWithMockError() async throws {
        // Configure the adapter
        let configuration = AIServiceConfigurationTDD(apiKey: "test_api_key")
        try mockAdapter.configure(with: configuration)
        
        // Set up mock error
        mockAdapter.mockError = AIServiceErrorTDD.apiError("Mock API error")
        
        // Try to extract text
        do {
            _ = try await mockAdapter.extractTextFromImage(NSImage())
            XCTFail("Should throw the mock error")
        } catch {
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.apiError("Mock API error"))
        }
        
        // Verify extractTextFromImage was called
        XCTAssertTrue(mockAdapter.extractTextWasCalled)
    }
}

// Extend AIServiceTypeTDD to include mock type for testing
extension AIServiceTypeTDD {
    static let mock = AIServiceTypeTDD(rawValue: "mock")!
}