# Context Menu Extension

This directory contains the code for the macOS context menu extension that adds the "Paste as Text" option.

## Responsibilities

- Add "Paste as Text" option to context menus where "Paste" appears
- Only enable when clipboard contains an image
- Invoke main application to process the image

## Key Files

- `ActionRequestHandler.swift`: Handles extension requests
- `Info.plist`: Extension configuration

## Extension Type

We're using an Action Extension (com.apple.ui-services) which can be configured to appear in context menus.