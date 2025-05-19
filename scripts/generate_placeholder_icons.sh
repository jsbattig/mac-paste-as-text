#!/bin/bash
# generate_placeholder_icons.sh - Script to generate placeholder icons for development
# Usage: ./scripts/generate_placeholder_icons.sh

set -e  # Exit immediately if a command exits with a non-zero status

# Default values
OUTPUT_DIR="resources/icons"
TEMP_DIR="/tmp/paste-as-text-icons"

# Print script information
echo "Generating placeholder icons for Paste as Text"
echo "Output directory: $OUTPUT_DIR"

# Check if required tools are installed
if ! command -v sips &> /dev/null; then
    echo "Error: sips is not available (should be installed on macOS by default)"
    exit 1
fi

if ! command -v iconutil &> /dev/null; then
    echo "Error: iconutil is not available (should be installed on macOS by default)"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Function to generate a placeholder icon with text
generate_icon() {
    local size=$1
    local text=$2
    local output_file=$3
    
    # Create a blank image with transparent background
    convert -size ${size}x${size} xc:none "$TEMP_DIR/blank.png"
    
    # Add a rounded rectangle background
    convert "$TEMP_DIR/blank.png" \
        -fill "#007AFF" \
        -draw "roundrectangle 0,0,${size},${size},20,20" \
        "$TEMP_DIR/bg.png"
    
    # Add text
    convert "$TEMP_DIR/bg.png" \
        -fill white \
        -font Arial \
        -pointsize $((size / 4)) \
        -gravity center \
        -annotate 0 "$text" \
        "$output_file"
    
    echo "Generated $output_file (${size}x${size})"
}

# Check if ImageMagick is installed
if command -v convert &> /dev/null; then
    echo "Using ImageMagick to generate placeholder icons..."
    
    # Generate app icon in various sizes
    generate_icon 1024 "PaT" "$OUTPUT_DIR/AppIcon-1024.png"
    generate_icon 512 "PaT" "$OUTPUT_DIR/AppIcon-512.png"
    generate_icon 256 "PaT" "$OUTPUT_DIR/AppIcon-256.png"
    generate_icon 128 "PaT" "$OUTPUT_DIR/AppIcon-128.png"
    generate_icon 64 "PaT" "$OUTPUT_DIR/AppIcon-64.png"
    generate_icon 32 "PaT" "$OUTPUT_DIR/AppIcon-32.png"
    generate_icon 16 "PaT" "$OUTPUT_DIR/AppIcon-16.png"
    
    # Generate preference pane icon
    generate_icon 512 "PaT" "$OUTPUT_DIR/PrefPaneIcon-512.png"
    
    # Generate extension icon
    generate_icon 32 "PaT" "$OUTPUT_DIR/ExtensionIcon-32.png"
else
    echo "ImageMagick not found. Using sips to create basic placeholder icons..."
    
    # Create a basic colored square as placeholder
    echo '<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
    <rect width="1024" height="1024" rx="200" ry="200" fill="#007AFF"/>
    <text x="512" y="512" font-family="Arial" font-size="400" text-anchor="middle" fill="white" dominant-baseline="middle">PaT</text>
    </svg>' > "$TEMP_DIR/AppIcon.svg"
    
    # Check if rsvg-convert is available to convert SVG to PNG
    if command -v rsvg-convert &> /dev/null; then
        rsvg-convert -w 1024 -h 1024 "$TEMP_DIR/AppIcon.svg" -o "$OUTPUT_DIR/AppIcon-1024.png"
        echo "Generated $OUTPUT_DIR/AppIcon-1024.png (1024x1024)"
    else
        echo "Neither ImageMagick nor rsvg-convert is available."
        echo "Please install one of these tools or manually create placeholder icons."
        exit 1
    fi
fi

# Create iconset directory for app icon
mkdir -p "$TEMP_DIR/AppIcon.iconset"

# Generate different sizes for iconset
sips -z 16 16 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_16x16.png"
sips -z 32 32 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_16x16@2x.png"
sips -z 32 32 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_32x32.png"
sips -z 64 64 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_32x32@2x.png"
sips -z 128 128 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_128x128.png"
sips -z 256 256 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_128x128@2x.png"
sips -z 256 256 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_256x256.png"
sips -z 512 512 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_256x256@2x.png"
sips -z 512 512 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_512x512.png"
sips -z 1024 1024 "$OUTPUT_DIR/AppIcon-1024.png" --out "$TEMP_DIR/AppIcon.iconset/icon_512x512@2x.png"

# Create iconset directory for preference pane icon
mkdir -p "$TEMP_DIR/PrefPaneIcon.iconset"

# Generate different sizes for preference pane iconset
sips -z 16 16 "$OUTPUT_DIR/PrefPaneIcon-512.png" --out "$TEMP_DIR/PrefPaneIcon.iconset/icon_16x16.png"
sips -z 32 32 "$OUTPUT_DIR/PrefPaneIcon-512.png" --out "$TEMP_DIR/PrefPaneIcon.iconset/icon_16x16@2x.png"
sips -z 32 32 "$OUTPUT_DIR/PrefPaneIcon-512.png" --out "$TEMP_DIR/PrefPaneIcon.iconset/icon_32x32.png"
sips -z 64 64 "$OUTPUT_DIR/PrefPaneIcon-512.png" --out "$TEMP_DIR/PrefPaneIcon.iconset/icon_32x32@2x.png"
sips -z 128 128 "$OUTPUT_DIR/PrefPaneIcon-512.png" --out "$TEMP_DIR/PrefPaneIcon.iconset/icon_128x128.png"
sips -z 256 256 "$OUTPUT_DIR/PrefPaneIcon-512.png" --out "$TEMP_DIR/PrefPaneIcon.iconset/icon_128x128@2x.png"
sips -z 256 256 "$OUTPUT_DIR/PrefPaneIcon-512.png" --out "$TEMP_DIR/PrefPaneIcon.iconset/icon_256x256.png"
sips -z 512 512 "$OUTPUT_DIR/PrefPaneIcon-512.png" --out "$TEMP_DIR/PrefPaneIcon.iconset/icon_256x256@2x.png"
sips -z 512 512 "$OUTPUT_DIR/PrefPaneIcon-512.png" --out "$TEMP_DIR/PrefPaneIcon.iconset/icon_512x512.png"

# Convert iconsets to icns files
iconutil -c icns "$TEMP_DIR/AppIcon.iconset" -o "$OUTPUT_DIR/AppIcon.icns"
iconutil -c icns "$TEMP_DIR/PrefPaneIcon.iconset" -o "$OUTPUT_DIR/PrefPaneIcon.icns"

echo "Generated $OUTPUT_DIR/AppIcon.icns"
echo "Generated $OUTPUT_DIR/PrefPaneIcon.icns"

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo "Placeholder icons generated successfully!"
echo "Note: These are simple placeholder icons for development purposes."
echo "For production, professional icons should be designed following Apple's Human Interface Guidelines."

exit 0