# Developer Guide

This guide provides information for developers who want to understand the codebase and contribute to the "Paste as Text" project.

## Project Architecture

The project follows Domain-Driven Design (DDD) principles and is structured into several components:

### Main Components

1. **Main Application**
   - Handles the core functionality
   - Processes images from the clipboard
   - Communicates with AI services
   - Manages user preferences

2. **Context Menu Extension**
   - Adds the "Paste as Text" option to context menus
   - Detects when the clipboard contains an image
   - Invokes the main application

3. **Preference Pane**
   - Integrates with macOS System Preferences
   - Provides UI for configuring the extension
   - Manages API keys and settings

### Domain Model

The domain model consists of:

1. **Entities**
   - `ImageContent`: Represents an image from the clipboard

2. **Value Objects**
   - `ExtractedText`: Immutable result of OCR

3. **Services**
   - `AIServiceAdapter`: Interface for AI services
   - `GeminiAdapter`: Implementation for Google Gemini
   - `AIServiceManager`: Manages AI service adapters

4. **Utilities**
   - `ClipboardManager`: Handles clipboard operations
   - `PreferencesManager`: Manages user preferences
   - `KeychainManager`: Securely stores API keys

## Code Organization

```
/
├── src/                      # Source code
│   ├── app/                  # Main application
│   │   ├── AppDelegate.swift # Main app delegate
│   │   ├── main.swift        # Entry point
│   │   └── Info.plist        # App configuration
│   ├── extension/            # Context menu extension
│   │   ├── ActionRequestHandler.swift # Extension handler
│   │   └── Info.plist        # Extension configuration
│   ├── settings/             # Preference pane
│   │   ├── PasteAsTextPreferencePane.swift # Preference pane UI
│   │   ├── PreferencesManager.swift # Settings management
│   │   ├── KeychainManager.swift # API key storage
│   │   └── Info.plist        # Preference pane configuration
│   ├── domain/               # Domain model
│   │   ├── entities/         # Entity classes
│   │   │   └── ImageContent.swift # Image entity
│   │   └── value_objects/    # Value object classes
│   │       └── ExtractedText.swift # Extracted text value object
│   ├── services/             # AI service adapters
│   │   ├── AIServiceAdapter.swift # Common interface
│   │   ├── GeminiAdapter.swift # Google Gemini implementation
│   │   └── AIServiceManager.swift # Service management
│   └── utils/                # Utility functions
│       └── ClipboardManager.swift # Clipboard operations
├── tests/                    # Test files
│   ├── unit/                 # Unit tests
│   │   ├── GeminiAdapterTests.swift # Tests for Gemini adapter
│   │   └── ClipboardManagerTests.swift # Tests for clipboard manager
│   ├── integration/          # Integration tests
│   └── ui/                   # UI tests
├── resources/                # Static resources
│   └── icons/                # Application icons
├── scripts/                  # Build and deployment scripts
│   ├── build_dmg.sh          # Script to create DMG package
│   └── setup_xcode_project.sh # Script to set up Xcode project
└── docs/                     # Documentation
    ├── user_guide.md         # User guide
    ├── xcode_setup_guide.md  # Xcode setup guide
    └── developer_guide.md    # This file
```

## Development Principles

### Domain-Driven Design (DDD)

The project follows DDD principles:

- **Ubiquitous Language**: Common terminology throughout the codebase
- **Bounded Contexts**: Clear separation of concerns
- **Entities and Value Objects**: Distinct modeling of objects with identity vs. immutable values
- **Aggregates**: Groups of related objects treated as a unit

### Test-Driven Development (TDD)

The development process follows TDD:

1. Write a failing test
2. Implement the minimum code to make the test pass
3. Refactor while keeping tests passing

### KISS and DRY Principles

- **KISS (Keep It Simple, Stupid)**: Favor simple, straightforward implementations
- **DRY (Don't Repeat Yourself)**: Extract common functionality into shared utilities

## Key Workflows

### Image to Text Extraction

1. User copies an image to the clipboard
2. User right-clicks and selects "Paste as Text"
3. Extension detects image in clipboard
4. Extension invokes main application via custom URL scheme
5. Main application reads image from clipboard
6. Main application sends image to selected AI service
7. AI service extracts text from image
8. Main application writes text to clipboard
9. Text is pasted at cursor position (if auto-paste is enabled)

### Settings Management

1. User opens System Preferences
2. User selects Paste as Text preference pane
3. User configures settings (AI service, API key, etc.)
4. Settings are saved to UserDefaults
5. API keys are securely stored in Keychain

## Adding a New AI Service

To add support for a new AI service:

1. Create a new adapter class that implements the `AIServiceAdapter` protocol
2. Add the new service type to the `AIServiceType` enum
3. Register the adapter in the `AIServiceManager`
4. Update the UI to include the new service option
5. Add tests for the new adapter

Example:

```swift
// 1. Create adapter
class NewServiceAdapter: AIServiceAdapter {
    var serviceType: AIServiceType { return .newService }
    var isConfigured: Bool { return apiKey != nil }
    private var apiKey: String?
    
    func configure(with configuration: AIServiceConfiguration) throws {
        self.apiKey = configuration.apiKey
        // Additional configuration
    }
    
    func extractTextFromImage(_ image: NSImage) async throws -> String {
        // Implementation for the new service
    }
}

// 2. Add service type
enum AIServiceType: String, CaseIterable {
    case gemini
    case openAI
    case anthropic
    case newService // New service type
    
    var displayName: String {
        switch self {
        case .gemini: return "Google Gemini"
        case .openAI: return "OpenAI"
        case .anthropic: return "Anthropic Claude"
        case .newService: return "New Service" // Display name
        }
    }
}

// 3. Register adapter
// In AIServiceManager.init()
registerServiceAdapter(NewServiceAdapter())
```

## Error Handling

The project uses a consistent error handling approach:

1. Domain-specific errors are defined in enums (e.g., `AIServiceError`)
2. Errors are propagated up the call stack
3. User-friendly error messages are provided via notifications
4. Detailed error information is logged (if debug logging is enabled)

## Logging

The project uses a simple logging system:

```swift
// Example logging (not yet implemented)
Logger.debug("Detailed debug information")
Logger.info("General information")
Logger.warning("Warning message")
Logger.error("Error message")
```

Logging is controlled by the `debugLogging` preference.

## Building and Testing

### Building

1. Set up the Xcode project using the [Xcode Setup Guide](xcode_setup_guide.md)
2. Build the project in Xcode (⌘B)

### Testing

1. Run the unit tests in Xcode (⌘U)
2. Run the integration tests
3. Run the UI tests

### Continuous Integration

The project uses GitHub Actions for CI/CD:

1. Automated builds on push/PR
2. Running tests
3. Creating DMG packages for releases

## Contributing

To contribute to the project:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for your changes
5. Ensure all tests pass
6. Submit a pull request

### Code Style Guidelines

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions small and focused
- Use Swift's type system to prevent errors

### Documentation

- Update documentation when making significant changes
- Document public APIs with documentation comments
- Keep the README and guides up to date

## Resources

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Test-Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- [macOS App Extension Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/index.html)