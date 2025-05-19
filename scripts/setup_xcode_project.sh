#!/bin/bash
# setup_xcode_project.sh - Script to set up the Xcode project
# Usage: ./scripts/setup_xcode_project.sh

set -e  # Exit immediately if a command exits with a non-zero status

# Default values
PROJECT_NAME="PasteAsText"
ORGANIZATION_NAME="PasteAsText"
BUNDLE_ID_PREFIX="com.pasteAsText"
MACOS_DEPLOYMENT_TARGET="12.0"

# Print script information
echo "Setting up Xcode project for $PROJECT_NAME"
echo "macOS Deployment Target: $MACOS_DEPLOYMENT_TARGET"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode is not installed or xcodebuild is not in the PATH"
    exit 1
fi

# Create a new Xcode project
echo "Creating Xcode project..."

# Check if the project already exists
if [ -d "$PROJECT_NAME.xcodeproj" ]; then
    echo "Warning: $PROJECT_NAME.xcodeproj already exists"
    read -p "Do you want to overwrite it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting..."
        exit 1
    fi
    rm -rf "$PROJECT_NAME.xcodeproj"
fi

# Create the project directory structure if it doesn't exist
mkdir -p "$PROJECT_NAME"

# Create a basic project structure
echo "Creating project structure..."

# Main App Target
echo "Setting up main app target..."
mkdir -p "$PROJECT_NAME/App"
cp -r src/app/* "$PROJECT_NAME/App/"

# Extension Target
echo "Setting up extension target..."
mkdir -p "$PROJECT_NAME/Extension"
cp -r src/extension/* "$PROJECT_NAME/Extension/"

# Preference Pane Target
echo "Setting up preference pane target..."
mkdir -p "$PROJECT_NAME/PreferencePane"
cp -r src/settings/* "$PROJECT_NAME/PreferencePane/"

# Shared Code
echo "Setting up shared code..."
mkdir -p "$PROJECT_NAME/Shared"
cp -r src/domain "$PROJECT_NAME/Shared/"
cp -r src/services "$PROJECT_NAME/Shared/"
cp -r src/utils "$PROJECT_NAME/Shared/"

# Resources
echo "Setting up resources..."
mkdir -p "$PROJECT_NAME/Resources"
cp -r resources/* "$PROJECT_NAME/Resources/"

# Create a basic project.pbxproj file
echo "Creating project configuration..."

# Note: Creating a full Xcode project programmatically is complex
# This script provides the structure, but you'll need to open Xcode
# and create a new project, then add the existing files

echo "Project structure created."
echo ""
echo "Next steps:"
echo "1. Open Xcode and create a new macOS app project named $PROJECT_NAME"
echo "2. Add the Extension target (File > New > Target > macOS > App Extension > Action Extension)"
echo "3. Add the Preference Pane target (File > New > Target > macOS > Bundle > Preference Pane)"
echo "4. Add the existing files to the appropriate targets"
echo "5. Configure the build settings for each target"
echo ""
echo "For detailed instructions, see the README.md file."

exit 0