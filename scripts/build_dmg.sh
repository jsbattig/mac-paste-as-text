#!/bin/bash
# build_dmg.sh - Script to create a DMG package for distribution
# Usage: ./scripts/build_dmg.sh [path/to/app]

set -e  # Exit immediately if a command exits with a non-zero status

# Default values
APP_PATH=${1:-"build/Release/Paste as Text.app"}
DMG_NAME="PasteAsText.dmg"
VOLUME_NAME="Paste as Text"
ICON_PATH="resources/icons/AppIcon.icns"
OUTPUT_DIR="dist"

# Print script information
echo "Building DMG package for Paste as Text"
echo "App path: $APP_PATH"
echo "DMG name: $DMG_NAME"

# Check if create-dmg is installed
if ! command -v create-dmg &> /dev/null; then
    echo "Error: create-dmg is not installed"
    echo "Please install it using: brew install create-dmg"
    exit 1
fi

# Check if the app exists
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH"
    echo "Please build the app first or provide the correct path"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Remove existing DMG if it exists
if [ -f "$OUTPUT_DIR/$DMG_NAME" ]; then
    echo "Removing existing DMG..."
    rm "$OUTPUT_DIR/$DMG_NAME"
fi

# Create the DMG
echo "Creating DMG package..."
create-dmg \
  --volname "$VOLUME_NAME" \
  --volicon "$ICON_PATH" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "$VOLUME_NAME.app" 200 190 \
  --hide-extension "$VOLUME_NAME.app" \
  --app-drop-link 600 185 \
  "$OUTPUT_DIR/$DMG_NAME" \
  "$APP_PATH"

# Check if DMG was created successfully
if [ -f "$OUTPUT_DIR/$DMG_NAME" ]; then
    echo "DMG created successfully: $OUTPUT_DIR/$DMG_NAME"
    
    # Add instructions for users
    echo ""
    echo "Installation Instructions:"
    echo "1. Open the DMG file"
    echo "2. Drag the application to your Applications folder"
    echo "3. When launching for the first time, right-click and select \"Open\""
    echo "4. Click \"Open\" when prompted about the unidentified developer"
else
    echo "Error: Failed to create DMG"
    exit 1
fi

exit 0