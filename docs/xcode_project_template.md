# Xcode Project Template

This document provides a template for setting up the Xcode project for the "Paste as Text" macOS extension. It includes target configurations, build settings, and entitlements.

## Project Configuration

### Basic Project Settings

- **Project Name**: PasteAsText
- **Organization Name**: PasteAsText
- **Organization Identifier**: com.pasteAsText
- **Bundle Identifier Prefix**: com.pasteAsText
- **Deployment Target**: macOS 12.0+
- **Language**: Swift
- **User Interface**: SwiftUI

### Targets

The project should have the following targets:

1. **PasteAsText** (Main Application)
2. **PasteAsTextExtension** (Action Extension)
3. **PasteAsTextPreferencePane** (Preference Pane)
4. **PasteAsTextTests** (Unit Tests)

## Target Configurations

### 1. PasteAsText (Main Application)

#### Build Settings

```
PRODUCT_NAME = PasteAsText
PRODUCT_BUNDLE_IDENTIFIER = com.pasteAsText.app
MACOSX_DEPLOYMENT_TARGET = 12.0
SWIFT_VERSION = 5.0
INFOPLIST_FILE = src/app/Info.plist
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
ENABLE_HARDENED_RUNTIME = YES
CODE_SIGN_ENTITLEMENTS = PasteAsText/PasteAsText.entitlements
```

#### Entitlements (PasteAsText.entitlements)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
</dict>
</plist>
```

#### Source Files

- `src/app/AppDelegate.swift`
- `src/app/main.swift`
- `src/app/Info.plist`
- Shared code from `src/domain`, `src/services`, and `src/utils`

### 2. PasteAsTextExtension (Action Extension)

#### Build Settings

```
PRODUCT_NAME = PasteAsTextExtension
PRODUCT_BUNDLE_IDENTIFIER = com.pasteAsText.app.extension
MACOSX_DEPLOYMENT_TARGET = 12.0
SWIFT_VERSION = 5.0
INFOPLIST_FILE = src/extension/Info.plist
ENABLE_HARDENED_RUNTIME = YES
CODE_SIGN_ENTITLEMENTS = PasteAsTextExtension/PasteAsTextExtension.entitlements
```

#### Entitlements (PasteAsTextExtension.entitlements)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
</dict>
</plist>
```

#### Source Files

- `src/extension/ActionRequestHandler.swift`
- `src/extension/Info.plist`
- Shared code from `src/domain`, `src/services`, and `src/utils`

### 3. PasteAsTextPreferencePane (Preference Pane)

#### Build Settings

```
PRODUCT_NAME = PasteAsTextPreferencePane
PRODUCT_BUNDLE_IDENTIFIER = com.pasteAsText.app.prefpane
MACOSX_DEPLOYMENT_TARGET = 12.0
SWIFT_VERSION = 5.0
INFOPLIST_FILE = src/settings/Info.plist
WRAPPER_EXTENSION = prefPane
ENABLE_HARDENED_RUNTIME = YES
CODE_SIGN_ENTITLEMENTS = PasteAsTextPreferencePane/PasteAsTextPreferencePane.entitlements
```

#### Entitlements (PasteAsTextPreferencePane.entitlements)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
</dict>
</plist>
```

#### Source Files

- `src/settings/PasteAsTextPreferencePane.swift`
- `src/settings/PreferencesManager.swift`
- `src/settings/KeychainManager.swift`
- `src/settings/Info.plist`
- Shared code from `src/domain`, `src/services`, and `src/utils`

### 4. PasteAsTextTests (Unit Tests)

#### Build Settings

```
PRODUCT_NAME = PasteAsTextTests
PRODUCT_BUNDLE_IDENTIFIER = com.pasteAsText.tests
MACOSX_DEPLOYMENT_TARGET = 12.0
SWIFT_VERSION = 5.0
TEST_HOST = $(BUILT_PRODUCTS_DIR)/PasteAsText.app/Contents/MacOS/PasteAsText
```

#### Source Files

- `tests/unit/GeminiAdapterTests.swift`
- `tests/unit/ClipboardManagerTests.swift`
- Other test files

## Shared Code

The following code should be shared across targets:

### Domain Model

- `src/domain/entities/ImageContent.swift`
- `src/domain/value_objects/ExtractedText.swift`

### Services

- `src/services/AIServiceAdapter.swift`
- `src/services/GeminiAdapter.swift`
- `src/services/AIServiceManager.swift`

### Utilities

- `src/utils/ClipboardManager.swift`

## Resources

### Icons

- `resources/icons/AppIcon.icns`
- `resources/icons/PrefPaneIcon.icns`
- `resources/icons/ExtensionIcon.png`

## Build Phases

### Main App

1. **Compile Sources**
2. **Link Binary With Libraries**
   - Cocoa.framework
   - Security.framework
3. **Copy Bundle Resources**
   - Info.plist
   - Icons
4. **Embed App Extensions**
   - PasteAsTextExtension.appex

### Extension

1. **Compile Sources**
2. **Link Binary With Libraries**
   - Cocoa.framework
3. **Copy Bundle Resources**
   - Info.plist
   - Icons

### Preference Pane

1. **Compile Sources**
2. **Link Binary With Libraries**
   - Cocoa.framework
   - PreferencePanes.framework
   - Security.framework
3. **Copy Bundle Resources**
   - Info.plist
   - Icons

## Schemes

### PasteAsText

- **Build**: All targets
- **Run**: PasteAsText
- **Test**: PasteAsTextTests

## Notes

- This template provides a starting point for setting up the Xcode project
- Actual implementation may require adjustments based on specific requirements
- Follow the [Xcode Setup Guide](xcode_setup_guide.md) for detailed instructions