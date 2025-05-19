# Paste as Text - Key Decisions

This document records key decisions made during the development of the "Paste as Text" macOS extension, including the options considered, rationale, and impact assessment.

## Initial Architecture Decisions

### Decision 1: Extension Type

**Decision Point**: What type of macOS extension to use for context menu integration

**Options Considered**:
1. **Action Extension**: Appears in the Services menu and can be configured to appear in context menus
2. **Share Extension**: Appears in Share menus throughout macOS
3. **Finder Sync Extension**: Extends Finder functionality but limited to Finder contexts
4. **Custom implementation**: Using lower-level APIs to modify context menus

**Decision**: Use Action Extension

**Rationale**:
- Action Extensions can be configured to appear in context menus where "Paste" appears
- Provides better integration with the system than custom implementations
- More flexible than Share Extensions for our specific use case
- Follows Apple's recommended approach for extending system functionality

**Impact**:
- Ensures proper integration with macOS
- Limits some customization options
- Requires proper configuration to appear in the right contexts
- Provides a familiar user experience consistent with macOS

### Decision 2: Initial AI Service

**Decision Point**: Which AI service to prioritize for the initial implementation

**Options Considered**:
1. **Google Gemini**: Free tier with rate limits, good OCR capabilities
2. **OpenAI (GPT-4 Vision)**: Excellent OCR but more expensive
3. **Anthropic Claude**: Strong OCR capabilities with different pricing
4. **Local OCR (Tesseract)**: Free, offline, but less accurate

**Decision**: Start with Google Gemini but design for easy switching between services

**Rationale**:
- Gemini offers a free tier with reasonable rate limits
- Good OCR capabilities for most use cases
- Cost-effective for initial development and testing
- Architecture will support easy addition of other services

**Impact**:
- Reduces initial development costs
- May require handling rate limits
- Provides a path to support other services
- Allows for comparison between services in the future

### Decision 3: Settings UI Implementation

**Decision Point**: How to implement the settings UI

**Options Considered**:
1. **System Preferences Integration**: Integrate with macOS System Preferences/Settings app
2. **Standalone Settings App**: Create a separate app for settings
3. **Menu Bar Item**: Implement settings directly in a menu bar app
4. **Hybrid Approach**: Basic settings in System Preferences, advanced in the app

**Decision**: Integrate with macOS System Preferences/Settings app

**Rationale**:
- Follows macOS conventions for system extensions
- Provides a familiar location for users to find settings
- Leverages system UI for consistency
- Appropriate for the scope of settings needed

**Impact**:
- Requires implementing a PreferencePane
- Limits some UI flexibility
- Provides better user experience for a system utility
- May require updates for different macOS versions

## Technical Implementation Decisions

### Decision 4: Architecture Pattern

**Decision Point**: What architecture pattern to use for the application

**Options Considered**:
1. **MVC (Model-View-Controller)**: Traditional pattern used in many macOS apps
2. **MVVM (Model-View-ViewModel)**: Better separation of concerns
3. **Clean Architecture**: More complex but highly modular
4. **Domain-Driven Design**: Focus on business domain

**Decision**: Use Domain-Driven Design with MVVM for UI components

**Rationale**:
- DDD provides clear separation of domain logic
- MVVM works well with SwiftUI for UI components
- Combination provides good balance of structure and flexibility
- Aligns with the complexity of the application

**Impact**:
- More initial setup required
- Better maintainability in the long term
- Clearer separation of concerns
- Easier to test individual components

### Decision 5: API Key Storage

**Decision Point**: How to securely store API keys

**Options Considered**:
1. **macOS Keychain**: System-provided secure storage
2. **Encrypted File**: Custom encrypted storage
3. **User Defaults**: Simple but not secure
4. **iCloud Keychain**: Synced across devices but more complex

**Decision**: Use macOS Keychain

**Rationale**:
- Provides secure storage designed for sensitive information
- Native integration with macOS
- Well-documented API
- Handles encryption and security concerns

**Impact**:
- Requires proper error handling for Keychain operations
- More complex than simple storage options
- Provides better security for sensitive API keys
- Follows best practices for credential storage

### Decision 6: Testing Framework

**Decision Point**: What testing framework to use

**Options Considered**:
1. **XCTest**: Apple's native testing framework
2. **Quick and Nimble**: BDD-style testing
3. **Combination**: XCTest for unit tests, Quick/Nimble for behavior tests
4. **Custom approach**: Tailored testing solution

**Decision**: Use XCTest with XCUITest for UI testing

**Rationale**:
- XCTest is well-integrated with Xcode
- Provides both unit and UI testing capabilities
- No additional dependencies required
- Sufficient for our testing needs

**Impact**:
- Familiar framework for most Swift developers
- Good integration with Xcode and CI systems
- May be less expressive than BDD frameworks
- Covers all necessary testing scenarios

## Distribution and Deployment Decisions

### Decision 7: Distribution Method

**Decision Point**: How to distribute the application without an Apple Developer account

**Options Considered**:
1. **DMG Package**: Standard macOS distribution format
2. **ZIP Archive**: Simple compressed archive
3. **Installer Package**: More complex but provides installation options
4. **Homebrew**: Distribution via package manager

**Decision**: Use DMG package with instructions for bypassing Gatekeeper

**Rationale**:
- DMG is the standard distribution format for macOS applications
- Provides a familiar installation experience
- Allows for customization of the installation experience
- Can include instructions for bypassing Gatekeeper

**Impact**:
- Users will need to bypass Gatekeeper warnings
- Requires clear instructions for installation
- Provides professional presentation
- Follows macOS conventions

### Decision 8: CI/CD Approach

**Decision Point**: How to implement CI/CD without an Apple Developer account

**Options Considered**:
1. **GitHub Actions**: Cloud-based CI/CD with macOS runners
2. **Jenkins**: Self-hosted CI/CD
3. **CircleCI**: Cloud-based CI/CD with macOS support
4. **Manual Process**: No automation

**Decision**: Use GitHub Actions for building unsigned DMG packages

**Rationale**:
- GitHub Actions provides macOS runners
- Integrates well with GitHub repository
- Can automate building and packaging
- Free for open source projects

**Impact**:
- Requires setting up GitHub Actions workflow
- Cannot perform official code signing or notarization
- Automates build and package process
- Provides consistent builds

### Decision 9: Update Mechanism

**Decision Point**: How to handle application updates

**Options Considered**:
1. **Sparkle Framework**: Open-source update framework for macOS
2. **Manual Updates**: Require users to download new versions
3. **Custom Update Checker**: Build a custom solution
4. **GitHub Releases API**: Check for new releases on GitHub

**Decision**: Use Sparkle Framework for updates

**Rationale**:
- Sparkle is a mature, well-tested framework
- Provides delta updates to reduce download size
- Handles the entire update process
- Works well with unsigned applications

**Impact**:
- Requires integration of Sparkle framework
- Provides professional update experience
- Reduces friction for users to update
- Follows best practices for macOS applications

## User Experience Decisions

### Decision 10: Error Handling Approach

**Decision Point**: How to handle errors and provide feedback to users

**Options Considered**:
1. **Modal Alerts**: Show alert dialogs for errors
2. **Notification Center**: Use system notifications
3. **In-app Messaging**: Show errors within the application UI
4. **Log File**: Write errors to log without user notification

**Decision**: Use a combination of notifications and in-app messaging

**Rationale**:
- Notifications are non-intrusive for background operations
- In-app messaging provides context for errors during active use
- Combination provides appropriate feedback for different scenarios
- Follows macOS conventions for error reporting

**Impact**:
- Requires implementing both notification and in-app messaging systems
- Provides better user experience
- Avoids disrupting workflow with modal dialogs
- Ensures users are informed of important issues

### Decision 11: Clipboard Handling

**Decision Point**: How to handle clipboard operations

**Options Considered**:
1. **Direct Manipulation**: Directly read/write clipboard in extension
2. **Main App Delegation**: Have extension delegate to main app
3. **Hybrid Approach**: Extension checks clipboard, main app processes
4. **Background Service**: Use a background service for clipboard operations

**Decision**: Use main app for clipboard operations, triggered by extension

**Rationale**:
- Extensions have limited capabilities and resources
- Main app can handle more complex operations
- Provides better error handling and user feedback
- Allows for background processing of large images

**Impact**:
- Requires communication between extension and main app
- More complex architecture
- Better performance for resource-intensive operations
- Improved user experience for large images or slow networks