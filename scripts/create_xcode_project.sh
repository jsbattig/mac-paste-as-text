#!/bin/bash
# create_xcode_project.sh - Script to create the Xcode project programmatically
# Usage: ./scripts/create_xcode_project.sh

set -e  # Exit immediately if a command exits with a non-zero status

# Print script information
echo "Creating Xcode project for Paste as Text"

# Define variables
PROJECT_NAME="PasteAsText"
ORGANIZATION_NAME="PasteAsText"
ORGANIZATION_IDENTIFIER="com.pasteAsText"
DEPLOYMENT_TARGET="12.0"
SWIFT_VERSION="5.0"
PROJECT_DIR="$(pwd)"
XCODE_PROJECT_DIR="${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj"
XCODE_WORKSPACE_DIR="${PROJECT_DIR}/${PROJECT_NAME}.xcworkspace"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode is not installed or xcodebuild is not in the PATH"
    exit 1
fi

# Check if the project already exists
if [ -d "$XCODE_PROJECT_DIR" ]; then
    echo "Warning: Xcode project already exists at $XCODE_PROJECT_DIR"
    read -p "Do you want to continue and overwrite it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting..."
        exit 1
    fi
    
    # Backup existing project
    BACKUP_DIR="${PROJECT_DIR}/backup_$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing project to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -r "$XCODE_PROJECT_DIR" "$BACKUP_DIR"
    if [ -d "$XCODE_WORKSPACE_DIR" ]; then
        cp -r "$XCODE_WORKSPACE_DIR" "$BACKUP_DIR"
    fi
    
    # Remove existing project
    rm -rf "$XCODE_PROJECT_DIR"
    if [ -d "$XCODE_WORKSPACE_DIR" ]; then
        rm -rf "$XCODE_WORKSPACE_DIR"
    fi
fi

# Create project structure directories
mkdir -p "${PROJECT_DIR}/PasteAsText"
mkdir -p "${PROJECT_DIR}/PasteAsTextExtension"
mkdir -p "${PROJECT_DIR}/PasteAsTextPreferencePane"
mkdir -p "${PROJECT_DIR}/PasteAsTextTests"

# Copy entitlements files
echo "Copying entitlements files..."
cp "${PROJECT_DIR}/src/app/PasteAsText.entitlements" "${PROJECT_DIR}/PasteAsText/"
cp "${PROJECT_DIR}/src/extension/PasteAsTextExtension.entitlements" "${PROJECT_DIR}/PasteAsTextExtension/"
cp "${PROJECT_DIR}/src/settings/PasteAsTextPreferencePane.entitlements" "${PROJECT_DIR}/PasteAsTextPreferencePane/"

# Create Info.plist files
echo "Creating Info.plist files..."

# Main application Info.plist
cat > "${PROJECT_DIR}/PasteAsText/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>\$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 PasteAsText. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>pasteastext</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

# Extension Info.plist
cat > "${PROJECT_DIR}/PasteAsTextExtension/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>\$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionAttributes</key>
        <dict>
            <key>NSExtensionActivationRule</key>
            <string>TRUEPREDICATE</string>
            <key>NSExtensionServiceAllowsFinderPreviewItem</key>
            <true/>
            <key>NSExtensionServiceFinderPreviewLabel</key>
            <string>Paste as Text</string>
            <key>NSExtensionServiceRoleType</key>
            <string>NSExtensionServiceRoleTypeEditor</string>
        </dict>
        <key>NSExtensionMainStoryboard</key>
        <string>MainInterface</string>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.ui-services</string>
    </dict>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 PasteAsText. All rights reserved.</string>
</dict>
</plist>
EOF

# Preference Pane Info.plist
cat > "${PROJECT_DIR}/PasteAsTextPreferencePane/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIconFile</key>
    <string>PrefPaneIcon</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 PasteAsText. All rights reserved.</string>
    <key>NSMainNibFile</key>
    <string>PasteAsTextPreferencePane</string>
    <key>NSPrefPaneIconFile</key>
    <string>PrefPaneIcon.icns</string>
    <key>NSPrefPaneIconLabel</key>
    <string>Paste as Text</string>
    <key>NSPrincipalClass</key>
    <string>PasteAsTextPreferencePane</string>
</dict>
</plist>
EOF

# Create basic Swift files for each target
echo "Creating basic Swift files..."

# Main application
mkdir -p "${PROJECT_DIR}/PasteAsText/Sources"
cat > "${PROJECT_DIR}/PasteAsText/Sources/AppDelegate.swift" << EOF
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the application
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up before termination
    }
}
EOF

# Extension
mkdir -p "${PROJECT_DIR}/PasteAsTextExtension/Sources"
cat > "${PROJECT_DIR}/PasteAsTextExtension/Sources/ActionRequestHandler.swift" << EOF
import Foundation
import UniformTypeIdentifiers

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    
    func beginRequest(with context: NSExtensionContext) {
        // Handle the extension request
        context.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
EOF

# Copy the ActionViewController and storyboard
cp "${PROJECT_DIR}/src/extension/ActionViewController.swift" "${PROJECT_DIR}/PasteAsTextExtension/Sources/"
cp "${PROJECT_DIR}/src/extension/MainInterface.storyboard" "${PROJECT_DIR}/PasteAsTextExtension/"

# Preference Pane
mkdir -p "${PROJECT_DIR}/PasteAsTextPreferencePane/Sources"
cat > "${PROJECT_DIR}/PasteAsTextPreferencePane/Sources/PasteAsTextPreferencePane.swift" << EOF
import Cocoa
import PreferencePanes

class PasteAsTextPreferencePane: NSPreferencePane {
    
    override func mainViewDidLoad() {
        super.mainViewDidLoad()
        // Set up the preference pane
    }
}
EOF

# Copy the preference pane XIB
cp "${PROJECT_DIR}/src/settings/PasteAsTextPreferencePane.xib" "${PROJECT_DIR}/PasteAsTextPreferencePane/"

# Tests
mkdir -p "${PROJECT_DIR}/PasteAsTextTests/Sources"
cat > "${PROJECT_DIR}/PasteAsTextTests/Sources/PasteAsTextTests.swift" << EOF
import XCTest
@testable import PasteAsText

class PasteAsTextTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Set up for tests
    }
    
    override func tearDown() {
        // Clean up after tests
        super.tearDown()
    }
    
    func testExample() {
        // Example test
        XCTAssertTrue(true)
    }
}
EOF

# Create project.pbxproj file
echo "Creating project.pbxproj file..."
mkdir -p "${XCODE_PROJECT_DIR}"

# Use the template as a base
cp "${PROJECT_DIR}/docs/project.pbxproj.template" "${XCODE_PROJECT_DIR}/project.pbxproj"

# Create a basic xcscheme file
mkdir -p "${XCODE_PROJECT_DIR}/xcshareddata/xcschemes"
cat > "${XCODE_PROJECT_DIR}/xcshareddata/xcschemes/${PROJECT_NAME}.xcscheme" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1430"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "XXXXXXXX"
               BuildableName = "${PROJECT_NAME}.app"
               BlueprintName = "${PROJECT_NAME}"
               ReferencedContainer = "container:${PROJECT_NAME}.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "XXXXXXXX"
               BuildableName = "${PROJECT_NAME}Tests.xctest"
               BlueprintName = "${PROJECT_NAME}Tests"
               ReferencedContainer = "container:${PROJECT_NAME}.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "XXXXXXXX"
            BuildableName = "${PROJECT_NAME}.app"
            BlueprintName = "${PROJECT_NAME}"
            ReferencedContainer = "container:${PROJECT_NAME}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "XXXXXXXX"
            BuildableName = "${PROJECT_NAME}.app"
            BlueprintName = "${PROJECT_NAME}"
            ReferencedContainer = "container:${PROJECT_NAME}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF

# Create a workspace
mkdir -p "${XCODE_WORKSPACE_DIR}/xcshareddata"
cat > "${XCODE_WORKSPACE_DIR}/contents.xcworkspacedata" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:${PROJECT_NAME}.xcodeproj">
   </FileRef>
</Workspace>
EOF

# Copy TDD implementations to the project
echo "Copying TDD implementations..."

# Create directories for shared code
mkdir -p "${PROJECT_DIR}/Shared/Domain/Entities"
mkdir -p "${PROJECT_DIR}/Shared/Domain/ValueObjects"
mkdir -p "${PROJECT_DIR}/Shared/Services"
mkdir -p "${PROJECT_DIR}/Shared/Utils"

# Copy domain model
cp "${PROJECT_DIR}/src/domain/entities/ImageContentTDD.swift" "${PROJECT_DIR}/Shared/Domain/Entities/ImageContent.swift"
cp "${PROJECT_DIR}/src/domain/value_objects/ExtractedTextTDD.swift" "${PROJECT_DIR}/Shared/Domain/ValueObjects/ExtractedText.swift"

# Copy services
cp "${PROJECT_DIR}/src/services/AIServiceAdapterTDD.swift" "${PROJECT_DIR}/Shared/Services/AIServiceAdapter.swift"
cp "${PROJECT_DIR}/src/services/GeminiAdapterTDD.swift" "${PROJECT_DIR}/Shared/Services/GeminiAdapter.swift"

# Copy utilities
cp "${PROJECT_DIR}/src/utils/ClipboardManagerTDD.swift" "${PROJECT_DIR}/Shared/Utils/ClipboardManager.swift"

# Copy tests
mkdir -p "${PROJECT_DIR}/PasteAsTextTests/Tests"
cp "${PROJECT_DIR}/tests/unit/ClipboardManagerTDD.swift" "${PROJECT_DIR}/PasteAsTextTests/Tests/ClipboardManagerTests.swift"
cp "${PROJECT_DIR}/tests/unit/GeminiAdapterTDD.swift" "${PROJECT_DIR}/PasteAsTextTests/Tests/GeminiAdapterTests.swift"
cp "${PROJECT_DIR}/tests/unit/AIServiceAdapterTDD.swift" "${PROJECT_DIR}/PasteAsTextTests/Tests/AIServiceAdapterTests.swift"
cp "${PROJECT_DIR}/tests/unit/AIServiceManagerTDD.swift" "${PROJECT_DIR}/PasteAsTextTests/Tests/AIServiceManagerTests.swift"
cp "${PROJECT_DIR}/tests/unit/ImageContentTDD.swift" "${PROJECT_DIR}/PasteAsTextTests/Tests/ImageContentTests.swift"
cp "${PROJECT_DIR}/tests/unit/ExtractedTextTDD.swift" "${PROJECT_DIR}/PasteAsTextTests/Tests/ExtractedTextTests.swift"

# Update the class/struct names in the copied files
echo "Updating class/struct names in copied files..."
find "${PROJECT_DIR}/Shared" -name "*.swift" -type f -exec sed -i '' 's/TDD_Implementation//g' {} \;
find "${PROJECT_DIR}/Shared" -name "*.swift" -type f -exec sed -i '' 's/TDD//g' {} \;
find "${PROJECT_DIR}/PasteAsTextTests" -name "*.swift" -type f -exec sed -i '' 's/TDD_Implementation//g' {} \;
find "${PROJECT_DIR}/PasteAsTextTests" -name "*.swift" -type f -exec sed -i '' 's/TDD//g' {} \;

echo "Xcode project structure created successfully!"
echo "To open the project in Xcode, run:"
echo "open ${PROJECT_NAME}.xcodeproj"
echo ""
echo "Note: This script creates a basic Xcode project structure."
echo "You may need to adjust the project settings in Xcode to match your specific requirements."
echo "Refer to docs/xcode_project_template.md for detailed configuration information."

exit 0