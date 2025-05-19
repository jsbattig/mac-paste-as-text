# Settings UI

This directory contains the code for the System Preferences integration for the "Paste as Text" extension.

## Responsibilities

- Provide a user interface for configuring the extension
- Store and retrieve user preferences
- Manage API keys securely

## Key Files

- `PasteAsTextPreferencePane.swift`: Main preference pane class
- `PreferencesManager.swift`: Manages user preferences
- `KeychainManager.swift`: Handles secure storage of API keys

## Integration

This integrates with macOS System Preferences/Settings app as a preference pane, following macOS conventions for system extensions.