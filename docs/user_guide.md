# Paste as Text - User Guide

This guide explains how to use the "Paste as Text" macOS extension to extract text from images in your clipboard.

## Installation

### From DMG Package

1. Download the latest DMG package from the [Releases](https://github.com/jsbattig/mac-paste-as-text/releases) page
2. Open the DMG file
3. Drag the "Paste as Text" application to your Applications folder
4. When launching for the first time:
   - Right-click (or Control-click) on the app in Finder
   - Select "Open" from the context menu
   - Click "Open" in the warning dialog
5. The app will start and run in the background

### From Source

If you prefer to build from source, follow the instructions in the [Xcode Setup Guide](xcode_setup_guide.md).

## Initial Setup

Before using the extension, you need to configure an AI service:

1. Open System Preferences (System Settings)
2. Scroll down to find "Paste as Text" in the preference panes
3. Click on it to open the settings
4. Select your preferred AI service (Google Gemini is the default)
5. Enter your API key for the selected service
6. Click "Save"

### Getting an API Key

#### Google Gemini

1. Go to the [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy the API key and paste it into the Paste as Text settings

#### OpenAI

1. Go to the [OpenAI API Keys](https://platform.openai.com/api-keys) page
2. Sign in with your OpenAI account
3. Create a new API key
4. Copy the API key and paste it into the Paste as Text settings

#### Anthropic Claude

1. Go to the [Anthropic Console](https://console.anthropic.com/)
2. Sign in with your Anthropic account
3. Navigate to the API Keys section
4. Create a new API key
5. Copy the API key and paste it into the Paste as Text settings

## Using Paste as Text

### Basic Usage

1. Copy an image containing text to your clipboard
   - Take a screenshot (Shift+Command+4 or Shift+Command+5)
   - Copy an image from a document or website
   - Copy an image file in Finder

2. Go to where you want to paste the text
   - Any text editor, document, or text field

3. Right-click (or Control-click) to open the context menu
   - The "Paste as Text" option will appear if the clipboard contains an image

4. Select "Paste as Text" from the context menu
   - The app will extract text from the image
   - The extracted text will be copied to your clipboard
   - If auto-paste is enabled, the text will be automatically pasted

5. If auto-paste is disabled, manually paste the text (Command+V)

### Notifications

By default, you'll receive notifications about:
- When processing starts
- When text is successfully extracted
- If no text is found in the image
- If an error occurs

You can disable notifications in the settings.

## Settings

### General Settings

- **AI Service**: Select which AI service to use for text extraction
- **API Key**: Enter your API key for the selected service
- **Language**: Select your preferred language for OCR
- **Auto-Paste**: Automatically paste the extracted text
- **Show Notifications**: Show notifications about the extraction process

### Advanced Settings

- **Confidence Threshold**: Minimum confidence level for extracted text (0-100%)
- **Max Retries**: Number of times to retry if the API call fails
- **Debug Logging**: Enable detailed logging for troubleshooting

## Troubleshooting

### Common Issues

1. **"Paste as Text" option doesn't appear**
   - Make sure the clipboard contains an image
   - Restart the app
   - Check if the extension is enabled in System Preferences

2. **No text is extracted**
   - The image may not contain readable text
   - Try a clearer image
   - Try a different AI service

3. **Error: "AI service is not configured"**
   - Go to System Preferences and enter your API key

4. **Error: "Rate limit exceeded"**
   - Wait a few minutes and try again
   - Consider upgrading to a paid tier of the AI service

5. **Error: "Network error"**
   - Check your internet connection
   - Try again later

### Getting Help

If you encounter issues not covered in this guide:

1. Check the [GitHub Issues](https://github.com/jsbattig/mac-paste-as-text/issues) for similar problems
2. Open a new issue with:
   - A description of the problem
   - Steps to reproduce
   - Any error messages
   - Screenshots if applicable

## Privacy and Security

- Your images are sent to the selected AI service for text extraction
- API keys are stored securely in the macOS Keychain
- No data is stored or logged by the application (unless debug logging is enabled)
- The application does not collect any personal information

## Uninstalling

To uninstall Paste as Text:

1. Quit the application
2. Delete the application from your Applications folder
3. Open System Preferences
4. Right-click on the Paste as Text preference pane
5. Select "Remove Preference Pane"