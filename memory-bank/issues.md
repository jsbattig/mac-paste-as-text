# Paste as Text - Known Issues and Challenges

This document tracks known issues, challenges, and limitations in the "Paste as Text" macOS extension.

## Current Issues

### Development Issues

| Issue | Description | Priority | Status | Workaround |
|-------|-------------|----------|--------|------------|
| No Apple Developer Account | Unable to code sign or notarize the application | High | Active | Provide instructions for bypassing Gatekeeper |
| macOS Extension Limitations | Context menu extensions have limited capabilities | Medium | Active | Investigate alternative approaches |
| Testing Environment | Need to set up proper testing for macOS extensions | Medium | Pending | Manual testing in development |

### Technical Limitations

| Issue | Description | Priority | Status | Workaround |
|-------|-------------|----------|--------|------------|
| AI Service Rate Limits | Free tier of Gemini has rate limits | Medium | Active | Implement caching and rate limiting in the app |
| Image Format Compatibility | Some clipboard image formats may not be supported | Medium | Pending | Convert images to supported formats |
| Large Image Processing | Large images may cause performance issues | Medium | Pending | Implement image resizing before API calls |

### User Experience Issues

| Issue | Description | Priority | Status | Workaround |
|-------|-------------|----------|--------|------------|
| Gatekeeper Warnings | Users will see warnings for unsigned app | High | Active | Provide clear installation instructions |
| OCR Accuracy | AI services may not perfectly extract text | Medium | Active | Allow users to adjust confidence thresholds |
| Processing Latency | API calls introduce latency | Medium | Pending | Add progress indicators and background processing |

## Investigation Notes

### macOS Extension Capabilities

The macOS extension system has several limitations that affect our implementation:

1. **Context Menu Integration**
   - Extensions can add items to context menus, but with limited control over placement
   - May need to use NSMenuDelegate for more precise control
   - Need to investigate how to ensure the extension only appears when clipboard contains an image

2. **Clipboard Access**
   - Extensions have limited access to the clipboard
   - May need to use the main application for clipboard operations
   - Need to investigate communication between extension and main app

3. **Background Processing**
   - Extensions run with limited resources
   - Long-running tasks should be offloaded to the main application
   - Need to implement proper handoff between extension and main app

### AI Service Integration

Current challenges with AI service integration:

1. **Gemini API**
   - Rate limits on free tier (approximately 60 requests per minute)
   - Image size limitations (10MB)
   - Need to handle API changes and versioning

2. **Error Handling**
   - Need robust error handling for network issues
   - Must gracefully handle API rate limiting
   - Should provide meaningful error messages to users

3. **Response Parsing**
   - Different AI services return results in different formats
   - Need to normalize responses across services
   - Should handle partial or incomplete results

### Distribution Without Developer Account

Challenges related to distribution without an Apple Developer account:

1. **Code Signing**
   - Cannot officially code sign the application
   - Users will see Gatekeeper warnings
   - Need to provide clear instructions for bypassing warnings

2. **Notarization**
   - Cannot submit the app for Apple's notarization process
   - Additional security warnings for users
   - May limit distribution options

3. **Updates**
   - Cannot use Apple's update mechanisms
   - Need to implement custom update checking
   - Should consider using Sparkle framework

## Mitigation Strategies

### Short-term Mitigations

1. **For Unsigned Application**
   - Create detailed installation instructions
   - Include visual guides for bypassing Gatekeeper
   - Add in-app help for first-time setup

2. **For API Rate Limits**
   - Implement local caching of results
   - Add rate limiting in the application
   - Provide clear error messages when limits are reached

3. **For OCR Accuracy**
   - Implement image preprocessing
   - Allow users to adjust confidence thresholds
   - Provide feedback mechanism for poor results

### Long-term Solutions

1. **For Distribution Issues**
   - Consider obtaining an Apple Developer account in the future
   - Research alternative distribution methods
   - Investigate open source signing options

2. **For Extension Limitations**
   - Research alternative extension points
   - Consider implementing as a Services menu item
   - Explore Automation/AppleScript integration

3. **For Performance Issues**
   - Implement background processing
   - Add image optimization before API calls
   - Consider local OCR options for faster processing

## Tracking and Resolution

### Issue Tracking Process

1. **New Issues**
   - Document in this file with "New" status
   - Assign priority (High, Medium, Low)
   - Add investigation notes

2. **In Progress**
   - Update status to "Active"
   - Document current approach
   - Note any blockers

3. **Resolved Issues**
   - Update status to "Resolved"
   - Document solution
   - Add date of resolution

### Priority Definitions

- **High**: Blocks core functionality or significantly impacts user experience
- **Medium**: Affects functionality but has workarounds, or impacts secondary features
- **Low**: Minor issues, cosmetic problems, or edge cases

## Open Questions

1. **Extension Activation**
   - What is the most reliable way to detect images in clipboard?
   - How can we ensure the extension is only enabled when appropriate?
   - Can we detect image content type before activation?

2. **Settings Storage**
   - What is the best approach for sharing settings between extension and main app?
   - How should we handle sensitive data like API keys?
   - What is the optimal settings schema for future extensibility?

3. **Error Recovery**
   - How should we handle network failures during OCR?
   - What retry strategies are appropriate?
   - How can we provide meaningful feedback without disrupting workflow?