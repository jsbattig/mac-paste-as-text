# Paste as Text - Technical Details

## Development Environment

- **Xcode Version**: Latest stable (14+)
- **Swift Version**: 5.7+
- **Minimum macOS Version**: 12.0 (Monterey)
- **Target macOS Versions**: 12.0+

## Project Configuration

- **Bundle Identifier**: `com.pasteAsText.app`
- **Extension Bundle Identifier**: `com.pasteAsText.app.extension`
- **Category**: Productivity
- **Required Entitlements**:
  - `com.apple.security.app-sandbox`
  - `com.apple.security.files.user-selected.read-only`
  - `com.apple.security.network.client`
  - `com.apple.security.temporary-exception.mach-lookup.global-name`

## macOS Extension Implementation

### Action Extension

```swift
class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        // Check if clipboard contains an image
        guard let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            // No image in clipboard, disable menu item
            context.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        
        // Invoke main application to process the image
        let url = URL(string: "pasteAsText://process")!
        context.open(url, completionHandler: nil)
        
        // Complete the extension request
        context.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
```

### Info.plist Configuration

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>NSExtensionActivationRule</key>
        <dict>
            <key>NSExtensionActivationSupportsImageWithMaxCount</key>
            <integer>1</integer>
        </dict>
    </dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.ui-services</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).ActionRequestHandler</string>
</dict>
```

## Clipboard Handling

### Reading Images

```swift
func getImageFromClipboard() -> NSImage? {
    let pasteboard = NSPasteboard.general
    
    if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
        return image
    }
    
    return nil
}
```

### Writing Text

```swift
func writeTextToClipboard(_ text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
}
```

## AI Service Integration

### Common Interface

```swift
protocol AIServiceAdapter {
    var serviceType: AIServiceType { get }
    var isConfigured: Bool { get }
    
    func configure(with configuration: AIServiceConfiguration) throws
    func extractTextFromImage(_ image: NSImage) async throws -> String
}

enum AIServiceType: String, CaseIterable {
    case gemini
    case openAI
    case anthropic
    
    var displayName: String {
        switch self {
        case .gemini: return "Google Gemini"
        case .openAI: return "OpenAI"
        case .anthropic: return "Anthropic Claude"
        }
    }
}

struct AIServiceConfiguration {
    let apiKey: String
    let endpoint: URL?
    let additionalParameters: [String: Any]
}
```

### Gemini Implementation

```swift
class GeminiAdapter: AIServiceAdapter {
    var serviceType: AIServiceType { return .gemini }
    private var apiKey: String?
    private var endpoint: URL?
    
    var isConfigured: Bool {
        return apiKey != nil
    }
    
    func configure(with configuration: AIServiceConfiguration) throws {
        self.apiKey = configuration.apiKey
        self.endpoint = configuration.endpoint ?? URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent")
    }
    
    func extractTextFromImage(_ image: NSImage) async throws -> String {
        guard let apiKey = apiKey, let endpoint = endpoint else {
            throw AIServiceError.notConfigured
        }
        
        guard let imageData = image.tiffRepresentation else {
            throw AIServiceError.invalidImageFormat
        }
        
        let base64Image = imageData.base64EncodedString()
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
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
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIServiceError.apiError("Invalid response from Gemini API")
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let candidates = jsonResponse?["candidates"] as? [[String: Any]],
              let candidate = candidates.first,
              let content = candidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let part = parts.first,
              let text = part["text"] as? String else {
            throw AIServiceError.parsingError("Failed to parse Gemini API response")
        }
        
        return text
    }
}

enum AIServiceError: Error {
    case notConfigured
    case invalidImageFormat
    case apiError(String)
    case parsingError(String)
    case rateLimitExceeded
    case networkError(Error)
}
```

## Settings Storage

### UserDefaults for General Settings

```swift
class PreferencesManager {
    static let shared = PreferencesManager()
    
    private let defaults = UserDefaults.standard
    
    enum PreferenceKey: String {
        case selectedAIService
        case languagePreference
        case autoPaste
        case showNotifications
    }
    
    var selectedAIService: AIServiceType {
        get {
            guard let value = defaults.string(forKey: PreferenceKey.selectedAIService.rawValue),
                  let serviceType = AIServiceType(rawValue: value) else {
                return .gemini // Default service
            }
            return serviceType
        }
        set {
            defaults.set(newValue.rawValue, forKey: PreferenceKey.selectedAIService.rawValue)
        }
    }
    
    var languagePreference: String {
        get {
            return defaults.string(forKey: PreferenceKey.languagePreference.rawValue) ?? "en"
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.languagePreference.rawValue)
        }
    }
    
    var autoPaste: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.autoPaste.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.autoPaste.rawValue)
        }
    }
    
    var showNotifications: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.showNotifications.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.showNotifications.rawValue)
        }
    }
}
```

### Keychain for API Keys

```swift
class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.pasteAsText.app"
    
    func saveAPIKey(_ key: String, for serviceType: AIServiceType) throws {
        let account = serviceType.rawValue
        
        // Delete any existing key
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new key
        let keyData = key.data(using: .utf8)!
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
    }
    
    func getAPIKey(for serviceType: AIServiceType) throws -> String? {
        let account = serviceType.rawValue
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.readFailed(status)
        }
        
        guard let data = item as? Data, let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.conversionFailed
        }
        
        return key
    }
    
    func deleteAPIKey(for serviceType: AIServiceType) throws {
        let account = serviceType.rawValue
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)
    case conversionFailed
}
```

## System Preferences Integration

### PreferencePane Implementation

```swift
import PreferencePanes

@objc(PasteAsTextPreferencePane)
class PasteAsTextPreferencePane: NSPreferencePane {
    
    @IBOutlet weak var servicePopup: NSPopUpButton!
    @IBOutlet weak var apiKeyField: NSSecureTextField!
    @IBOutlet weak var languagePopup: NSPopUpButton!
    @IBOutlet weak var autoPasteCheckbox: NSButton!
    @IBOutlet weak var notificationsCheckbox: NSButton!
    
    override func mainViewDidLoad() {
        super.mainViewDidLoad()
        
        // Setup service popup
        servicePopup.removeAllItems()
        for serviceType in AIServiceType.allCases {
            servicePopup.addItem(withTitle: serviceType.displayName)
        }
        
        // Select current service
        let currentService = PreferencesManager.shared.selectedAIService
        servicePopup.selectItem(withTitle: currentService.displayName)
        
        // Load API key
        do {
            if let apiKey = try KeychainManager.shared.getAPIKey(for: currentService) {
                apiKeyField.stringValue = apiKey
            }
        } catch {
            // Handle error
            print("Failed to load API key: \(error)")
        }
        
        // Setup language popup
        languagePopup.removeAllItems()
        let languages = [
            ("English", "en"),
            ("Spanish", "es"),
            ("French", "fr"),
            ("German", "de"),
            ("Chinese", "zh"),
            ("Japanese", "ja")
        ]
        
        for (name, code) in languages {
            languagePopup.addItem(withTitle: name)
            languagePopup.lastItem?.representedObject = code
        }
        
        // Select current language
        let currentLanguage = PreferencesManager.shared.languagePreference
        for (index, (_, code)) in languages.enumerated() {
            if code == currentLanguage {
                languagePopup.selectItem(at: index)
                break
            }
        }
        
        // Setup checkboxes
        autoPasteCheckbox.state = PreferencesManager.shared.autoPaste ? .on : .off
        notificationsCheckbox.state = PreferencesManager.shared.showNotifications ? .on : .off
    }
    
    @IBAction func serviceChanged(_ sender: NSPopUpButton) {
        guard let title = sender.selectedItem?.title,
              let serviceType = AIServiceType.allCases.first(where: { $0.displayName == title }) else {
            return
        }
        
        PreferencesManager.shared.selectedAIService = serviceType
        
        // Update API key field
        do {
            if let apiKey = try KeychainManager.shared.getAPIKey(for: serviceType) {
                apiKeyField.stringValue = apiKey
            } else {
                apiKeyField.stringValue = ""
            }
        } catch {
            apiKeyField.stringValue = ""
            print("Failed to load API key: \(error)")
        }
    }
    
    @IBAction func saveAPIKey(_ sender: Any) {
        guard let title = servicePopup.selectedItem?.title,
              let serviceType = AIServiceType.allCases.first(where: { $0.displayName == title }) else {
            return
        }
        
        let apiKey = apiKeyField.stringValue
        
        do {
            try KeychainManager.shared.saveAPIKey(apiKey, for: serviceType)
        } catch {
            // Show error
            let alert = NSAlert()
            alert.messageText = "Failed to save API key"
            alert.informativeText = "There was an error saving your API key to the keychain."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    @IBAction func languageChanged(_ sender: NSPopUpButton) {
        guard let code = sender.selectedItem?.representedObject as? String else {
            return
        }
        
        PreferencesManager.shared.languagePreference = code
    }
    
    @IBAction func autoPasteChanged(_ sender: NSButton) {
        PreferencesManager.shared.autoPaste = (sender.state == .on)
    }
    
    @IBAction func notificationsChanged(_ sender: NSButton) {
        PreferencesManager.shared.showNotifications = (sender.state == .on)
    }
}
```

## DMG Creation

The DMG package will be created using the `create-dmg` tool in the CI/CD pipeline:

```bash
create-dmg \
  --volname "Paste as Text" \
  --volicon "resources/icons/AppIcon.icns" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "Paste as Text.app" 200 190 \
  --hide-extension "Paste as Text.app" \
  --app-drop-link 600 185 \
  "dist/PasteAsText.dmg" \
  "build/Release/Paste as Text.app"
```

## Handling Gatekeeper Warnings

Since the application will be unsigned (without an Apple Developer account), users will need to bypass Gatekeeper warnings. The following instructions will be included:

1. Download the DMG file
2. Open the DMG file
3. Drag the application to your Applications folder
4. When launching for the first time:
   - Right-click (or Control-click) on the app in Finder
   - Select "Open" from the context menu
   - Click "Open" in the warning dialog
5. After the first launch, the app can be opened normally

## Testing Strategy

### Unit Testing with XCTest

```swift
import XCTest
@testable import PasteAsText

class AIServiceAdapterTests: XCTestCase {
    
    var geminiAdapter: GeminiAdapter!
    
    override func setUp() {
        super.setUp()
        geminiAdapter = GeminiAdapter()
        
        // Configure with test API key
        let configuration = AIServiceConfiguration(
            apiKey: "test_api_key",
            endpoint: URL(string: "https://test-endpoint.example.com"),
            additionalParameters: [:]
        )
        
        try? geminiAdapter.configure(with: configuration)
    }
    
    func testIsConfigured() {
        XCTAssertTrue(geminiAdapter.isConfigured)
        
        let unconfiguredAdapter = GeminiAdapter()
        XCTAssertFalse(unconfiguredAdapter.isConfigured)
    }
    
    func testExtractTextFromImage() async {
        // Create a test image with text
        let image = createTestImage(withText: "Hello, World!")
        
        // Mock the network request
        // (Implementation depends on the testing approach)
        
        do {
            let extractedText = try await geminiAdapter.extractTextFromImage(image)
            XCTAssertEqual(extractedText, "Hello, World!")
        } catch {
            XCTFail("Text extraction failed with error: \(error)")
        }
    }
    
    private func createTestImage(withText text: String) -> NSImage {
        // Create a test image with the given text
        let size = NSSize(width: 400, height: 100)
        let image = NSImage(size: size)
        
        image.lockFocus()
        let rect = NSRect(origin: .zero, size: size)
        NSColor.white.set()
        rect.fill()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 24),
            .foregroundColor: NSColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let textRect = NSRect(x: 0, y: 40, width: size.width, height: 24)
        text.draw(in: textRect, withAttributes: attributes)
        
        image.unlockFocus()
        return image
    }
}
```

### UI Testing with XCUITest

```swift
import XCTest

class PasteAsTextUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testPreferencesUI() {
        // Open Preferences
        app.menuBars.menuBarItems["Paste as Text"].click()
        app.menuBars.menuItems["Preferences..."].click()
        
        // Verify preferences window appears
        let preferencesWindow = app.windows["Paste as Text Preferences"]
        XCTAssertTrue(preferencesWindow.exists)
        
        // Test service selection
        let servicePopup = preferencesWindow.popUpButtons["servicePopup"]
        XCTAssertTrue(servicePopup.exists)
        servicePopup.click()
        servicePopup.menuItems["OpenAI"].click()
        
        // Test API key field
        let apiKeyField = preferencesWindow.secureTextFields["apiKeyField"]
        XCTAssertTrue(apiKeyField.exists)
        apiKeyField.click()
        apiKeyField.typeText("test_api_key")
        
        // Test save button
        let saveButton = preferencesWindow.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.click()
        
        // Verify settings were saved (would need to check UserDefaults/Keychain)
    }
}