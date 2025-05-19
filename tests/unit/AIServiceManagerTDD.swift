import XCTest
@testable import PasteAsText

/// Unit tests for the AIServiceManager following TDD approach
class AIServiceManagerTDD: XCTestCase {
    
    /// Mock adapter for testing
    class MockAdapter: AIServiceAdapterProtocol {
        var serviceType: AIServiceTypeTDD
        var isConfigured: Bool = false
        var configureWasCalled = false
        var extractTextWasCalled = false
        var mockResponse: String?
        var mockError: AIServiceErrorTDD?
        
        init(serviceType: AIServiceTypeTDD) {
            self.serviceType = serviceType
        }
        
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
    
    /// The manager to test
    var manager: AIServiceManagerTDD!
    
    /// Mock adapters
    var geminiAdapter: MockAdapter!
    var openAIAdapter: MockAdapter!
    var anthropicAdapter: MockAdapter!
    
    /// Set up before each test
    override func setUp() {
        super.setUp()
        
        // Create a new manager for each test
        manager = AIServiceManagerTDD()
        
        // Create mock adapters
        geminiAdapter = MockAdapter(serviceType: .gemini)
        openAIAdapter = MockAdapter(serviceType: .openAI)
        anthropicAdapter = MockAdapter(serviceType: .anthropic)
        
        // Register mock adapters
        manager.registerServiceAdapter(geminiAdapter)
        manager.registerServiceAdapter(openAIAdapter)
        manager.registerServiceAdapter(anthropicAdapter)
    }
    
    /// Tear down after each test
    override func tearDown() {
        manager = nil
        geminiAdapter = nil
        openAIAdapter = nil
        anthropicAdapter = nil
        super.tearDown()
    }
    
    /// Test that Gemini is the default service
    func testDefaultServiceIsGemini() {
        XCTAssertEqual(manager.selectedServiceType, .gemini)
    }
    
    /// Test registering and retrieving adapters
    func testRegisterAndRetrieveAdapters() {
        // Verify adapters were registered
        XCTAssertTrue(manager.isServiceTypeAvailable(.gemini))
        XCTAssertTrue(manager.isServiceTypeAvailable(.openAI))
        XCTAssertTrue(manager.isServiceTypeAvailable(.anthropic))
        
        // Verify available service types
        let availableTypes = manager.getAvailableServiceTypes()
        XCTAssertEqual(availableTypes.count, 3)
        XCTAssertTrue(availableTypes.contains(.gemini))
        XCTAssertTrue(availableTypes.contains(.openAI))
        XCTAssertTrue(availableTypes.contains(.anthropic))
    }
    
    /// Test selecting a service type
    func testSelectServiceType() {
        // Select OpenAI
        let result = manager.selectServiceType(.openAI)
        
        // Verify selection was successful
        XCTAssertTrue(result)
        XCTAssertEqual(manager.selectedServiceType, .openAI)
        XCTAssertTrue(manager.selectedAdapter === openAIAdapter)
    }
    
    /// Test selecting an unavailable service type
    func testSelectUnavailableServiceType() {
        // Create a new manager without registering adapters
        let emptyManager = AIServiceManagerTDD()
        
        // Try to select Gemini
        let result = emptyManager.selectServiceType(.gemini)
        
        // Verify selection failed
        XCTAssertFalse(result)
        // Default should still be Gemini, even though it's not available
        XCTAssertEqual(emptyManager.selectedServiceType, .gemini)
        XCTAssertNil(emptyManager.selectedAdapter)
    }
    
    /// Test configuring the selected adapter
    func testConfigureSelectedAdapter() throws {
        // Create a valid configuration
        let configuration = AIServiceConfigurationTDD(apiKey: "test_api_key")
        
        // Configure the selected adapter (Gemini by default)
        try manager.configureSelectedAdapter(with: configuration)
        
        // Verify the adapter was configured
        XCTAssertTrue(geminiAdapter.configureWasCalled)
        XCTAssertTrue(geminiAdapter.isConfigured)
        XCTAssertTrue(manager.isSelectedAdapterConfigured())
    }
    
    /// Test configuring with invalid configuration
    func testConfigureWithInvalidConfiguration() {
        // Create an invalid configuration with empty API key
        let configuration = AIServiceConfigurationTDD(apiKey: "")
        
        // Configure the selected adapter - should throw an error
        XCTAssertThrowsError(try manager.configureSelectedAdapter(with: configuration)) { error in
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.invalidConfiguration)
        }
        
        // Verify the adapter was not configured
        XCTAssertTrue(geminiAdapter.configureWasCalled)
        XCTAssertFalse(geminiAdapter.isConfigured)
        XCTAssertFalse(manager.isSelectedAdapterConfigured())
    }
    
    /// Test configuring when no adapter is selected
    func testConfigureWithNoAdapter() {
        // Create a new manager without registering adapters
        let emptyManager = AIServiceManagerTDD()
        
        // Create a valid configuration
        let configuration = AIServiceConfigurationTDD(apiKey: "test_api_key")
        
        // Configure the selected adapter - should throw an error
        XCTAssertThrowsError(try emptyManager.configureSelectedAdapter(with: configuration)) { error in
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.notConfigured)
        }
    }
    
    /// Test extracting text from an image
    func testExtractTextFromImage() async throws {
        // Configure the selected adapter (Gemini by default)
        try manager.configureSelectedAdapter(with: AIServiceConfigurationTDD(apiKey: "test_api_key"))
        
        // Set up mock response
        geminiAdapter.mockResponse = "Test extracted text"
        
        // Extract text
        let extractedText = try await manager.extractTextFromImage(NSImage())
        
        // Verify the adapter was used and returned the mock response
        XCTAssertTrue(geminiAdapter.extractTextWasCalled)
        XCTAssertEqual(extractedText, "Test extracted text")
    }
    
    /// Test extracting text when no adapter is selected
    func testExtractTextWithNoAdapter() async {
        // Create a new manager without registering adapters
        let emptyManager = AIServiceManagerTDD()
        
        // Try to extract text
        do {
            _ = try await emptyManager.extractTextFromImage(NSImage())
            XCTFail("Should throw an error when no adapter is selected")
        } catch {
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.notConfigured)
        }
    }
    
    /// Test extracting text when adapter is not configured
    func testExtractTextWithUnconfiguredAdapter() async {
        // Try to extract text without configuring the adapter
        do {
            _ = try await manager.extractTextFromImage(NSImage())
            XCTFail("Should throw an error when adapter is not configured")
        } catch {
            XCTAssertEqual(error as? AIServiceErrorTDD, AIServiceErrorTDD.notConfigured)
        }
    }
}