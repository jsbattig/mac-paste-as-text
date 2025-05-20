#!/bin/bash
# setup_xcode_project.sh - Script to set up the Xcode project structure
# Usage: ./scripts/setup_xcode_project.sh

set -e  # Exit immediately if a command exits with a non-zero status

# Print script information
echo "Setting up Xcode project for Paste as Text"

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
fi

echo "This script will set up the Xcode project structure for the Paste as Text application."
echo "It will create the following targets:"
echo "1. PasteAsText (Main Application)"
echo "2. PasteAsTextExtension (Context Menu Extension)"
echo "3. PasteAsTextPreferencePane (Preference Pane)"
echo "4. PasteAsTextTests (Unit Tests)"
echo ""

echo "In a real implementation, this script would:"
echo "1. Create the Xcode project file structure"
echo "2. Set up the targets and build configurations"
echo "3. Configure the entitlements and capabilities"
echo "4. Set up the test environment"
echo "5. Import existing code into the project"
echo ""

echo "For now, this is a placeholder script. To create the Xcode project:"
echo "1. Open Xcode"
echo "2. Create a new macOS application project"
echo "3. Add the extension and preference pane targets"
echo "4. Configure the targets according to docs/xcode_project_template.md"
echo "5. Import the existing code from src/ and tests/"
echo ""

# Create project structure directories if they don't exist
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

echo "Created project structure and configuration files."
echo "Next steps:"
echo "1. Create the Xcode project using Xcode"
echo "2. Import the existing code"
echo "3. Configure the targets according to docs/xcode_project_template.md"
echo "4. Build and run the project"

exit 0