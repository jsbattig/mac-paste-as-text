# App Icons

This directory will contain the icons for the "Paste as Text" application.

## Required Icons

### App Icon

The main application icon should be provided in the following formats:

- `AppIcon.icns`: macOS app icon file
- `AppIcon.png`: High-resolution PNG (1024x1024)
- Various sizes for different display densities:
  - 16x16
  - 32x32
  - 64x64
  - 128x128
  - 256x256
  - 512x512
  - 1024x1024

### Preference Pane Icon

The icon for the System Preferences pane:

- `PrefPaneIcon.icns`: macOS preference pane icon
- `PrefPaneIcon.png`: High-resolution PNG (512x512)

### Extension Icon

The icon for the context menu extension:

- `ExtensionIcon.png`: PNG format (32x32)

## Design Guidelines

When creating icons, follow Apple's Human Interface Guidelines:

- Use a simple, recognizable design
- Maintain consistency across different sizes
- Use the macOS icon grid
- Consider light and dark mode appearances
- Avoid text in icons

## Icon Creation

You can use tools like:

- Sketch
- Figma
- Adobe Illustrator
- IconKit

To convert PNG files to ICNS format, you can use:

```bash
# Using iconutil (requires a .iconset directory)
iconutil -c icns MyIcon.iconset

# Using sips and iconutil
mkdir MyIcon.iconset
sips -z 16 16 MyIcon.png --out MyIcon.iconset/icon_16x16.png
sips -z 32 32 MyIcon.png --out MyIcon.iconset/icon_16x16@2x.png
# ... repeat for other sizes
iconutil -c icns MyIcon.iconset
```

## Placeholder

Until custom icons are created, you can use placeholder icons or system symbols.