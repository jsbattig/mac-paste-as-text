# Xcode Project Setup Guide

This guide provides detailed instructions for setting up the Xcode project for the "Paste as Text" macOS extension.

## Prerequisites

- Xcode 14 or later
- macOS 12.0 (Monterey) or later
- Basic knowledge of Xcode and Swift development

## Setup Steps

### 1. Run the Setup Script

The setup script will create the basic project structure:

```bash
./scripts/setup_xcode_project.sh
```

This script copies the source files into the appropriate directories for the Xcode project.

### 2. Create the Xcode Project

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "macOS" > "App"
4. Set the following options:
   - Product Name: "PasteAsText"
   - Team: Your development team (or none for personal use)
   - Organization Identifier: "com.pasteAsText"
   - Bundle Identifier: "com.pasteAsText.app"
   - Language: Swift
   - User Interface: SwiftUI (or Storyboard if you prefer)
   - Deselect "Include Tests" (we'll add them manually)
5. Choose a location to save the project (the root of the repository)

### 3. Add the Extension Target

1. In Xcode, select File > New > Target
2. Choose "macOS" > "App Extension" > "Action Extension"
3. Set the following options:
   - Product Name: "PasteAsTextExtension"
   - Team: Same as main app
   - Organization Identifier: "com.pasteAsText"
   - Bundle Identifier: "com.pasteAsText.app.extension"
   - Language: Swift
   - Embed in Application: PasteAsText
4. Click "Finish"

### 4. Add the Preference Pane Target

1. In Xcode, select File > New > Target
2. Choose "macOS" > "Bundle" > "Preference Pane"
3. Set the following options:
   - Product Name: "PasteAsTextPreferencePane"
   - Team: Same as main app
   - Organization Identifier: "com.pasteAsText"
   - Bundle Identifier: "com.pasteAsText.app.prefpane"
   - Language: Swift
4. Click "Finish"

### 5. Add Existing Files to the Project

#### Main App

1. In the Project Navigator, right-click on the main app target group
2. Select "Add Files to 'PasteAsText'..."
3. Navigate to "PasteAsText/App" directory created by the setup script
4. Select all files and click "Add"
5. Make sure "Copy items if needed" is unchecked
6. Select the main app target in the "Add to targets" section

#### Extension

1. In the Project Navigator, right-click on the extension target group
2. Select "Add Files to 'PasteAsTextExtension'..."
3. Navigate to "PasteAsText/Extension" directory
4. Select all files and click "Add"
5. Make sure "Copy items if needed" is unchecked
6. Select the extension target in the "Add to targets" section

#### Preference Pane

1. In the Project Navigator, right-click on the preference pane target group
2. Select "Add Files to 'PasteAsTextPreferencePane'..."
3. Navigate to "PasteAsText/PreferencePane" directory
4. Select all files and click "Add"
5. Make sure "Copy items if needed" is unchecked
6. Select the preference pane target in the "Add to targets" section

#### Shared Code

1. In the Project Navigator, right-click on the project root
2. Select "New Group" and name it "Shared"
3. Right-click on the "Shared" group
4. Select "Add Files to 'PasteAsText'..."
5. Navigate to "PasteAsText/Shared" directory
6. Select all files and click "Add"
7. Make sure "Copy items if needed" is unchecked
8. Select all targets in the "Add to targets" section

### 6. Configure Build Settings

#### Main App

1. Select the main app target in the Project Navigator
2. Go to the "Build Settings" tab
3. Set the following:
   - Deployment Target: macOS 12.0
   - Swift Language Version: Swift 5
   - Enable Hardened Runtime: Yes
   - App Sandbox: Yes
   - App Category: Productivity

#### Extension

1. Select the extension target
2. Go to the "Build Settings" tab
3. Set the following:
   - Deployment Target: macOS 12.0
   - Swift Language Version: Swift 5
   - Enable Hardened Runtime: Yes
   - App Sandbox: Yes

#### Preference Pane

1. Select the preference pane target
2. Go to the "Build Settings" tab
3. Set the following:
   - Deployment Target: macOS 12.0
   - Swift Language Version: Swift 5
   - Enable Hardened Runtime: Yes
   - App Sandbox: Yes

### 7. Configure Entitlements

#### Main App

1. Open the main app's entitlements file
2. Add the following entitlements:
   - App Sandbox: YES
   - Network: Outgoing Connections (Client): YES
   - User Selected Files: Read Only: YES

#### Extension

1. Open the extension's entitlements file
2. Add the following entitlements:
   - App Sandbox: YES
   - User Selected Files: Read Only: YES

### 8. Configure Info.plist Files

Replace the default Info.plist files with the ones from the repository:

1. Delete the auto-generated Info.plist files
2. Add the Info.plist files from the src/app, src/extension, and src/settings directories
3. Update the bundle identifiers if necessary

### 9. Add Resources

1. In the Project Navigator, right-click on the project root
2. Select "New Group" and name it "Resources"
3. Right-click on the "Resources" group
4. Select "Add Files to 'PasteAsText'..."
5. Navigate to "PasteAsText/Resources" directory
6. Select all files and click "Add"
7. Make sure "Copy items if needed" is unchecked
8. Select all targets in the "Add to targets" section

### 10. Add Tests

1. In Xcode, select File > New > Target
2. Choose "macOS" > "Unit Testing Bundle"
3. Set the product name to "PasteAsTextTests"
4. Click "Finish"
5. Add the test files from the tests directory

## Building and Running

### Building the App

1. Select the main app target in the scheme selector
2. Choose "My Mac" as the destination
3. Click the "Build" button (⌘B)

### Running the App

1. Select the main app target in the scheme selector
2. Choose "My Mac" as the destination
3. Click the "Run" button (⌘R)

### Testing

1. Select the test target in the scheme selector
2. Choose "My Mac" as the destination
3. Click the "Test" button (⌘U)

## Troubleshooting

### Common Issues

1. **Missing Files**: Ensure all files are added to the correct targets
2. **Build Errors**: Check that all dependencies are properly linked
3. **Entitlements Issues**: Verify that the entitlements are correctly configured
4. **Code Signing**: For development, you can use "Sign to Run Locally"

### Getting Help

If you encounter issues, please:

1. Check the project's GitHub issues
2. Consult the Apple Developer Documentation
3. Open a new issue with detailed information about the problem