import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    /// The main window controller
    var mainWindowController: NSWindowController?
    
    /// Application did finish launching
    /// - Parameter notification: The notification
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register for URL events
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
        
        // Set up the main window if needed
        setupMainWindow()
    }
    
    /// Handle URL events (custom URL scheme)
    /// - Parameters:
    ///   - event: The Apple event
    ///   - replyEvent: The reply event
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            return
        }
        
        // Handle the URL
        handleURL(url)
    }
    
    /// Handle a URL
    /// - Parameter url: The URL
    private func handleURL(_ url: URL) {
        // Check if this is our custom URL scheme
        guard url.scheme == "pasteAsText" else {
            return
        }
        
        // Handle different actions
        switch url.host {
        case "process":
            processClipboardImage()
        case "settings":
            showSettings()
        default:
            break
        }
    }
    
    /// Process an image from the clipboard
    private func processClipboardImage() {
        // Check if clipboard contains an image
        guard let imageContent = ClipboardManager.shared.getImageFromClipboard() else {
            showNotification(title: "No Image Found", body: "The clipboard does not contain an image.")
            return
        }
        
        // Extract text from the image
        Task {
            do {
                // Show processing notification
                if PreferencesManager.shared.showNotifications {
                    showNotification(title: "Processing Image", body: "Extracting text from image...")
                }
                
                // Extract text
                let extractedText = try await AIServiceManager.shared.extractText(from: imageContent)
                
                // Check if text was extracted
                if extractedText.isEmpty() {
                    showNotification(title: "No Text Found", body: "No text could be extracted from the image.")
                    return
                }
                
                // Write text to clipboard
                ClipboardManager.shared.writeExtractedTextToClipboard(extractedText)
                
                // Show success notification
                if PreferencesManager.shared.showNotifications {
                    let summary = extractedText.summary(maxWords: 5)
                    showNotification(title: "Text Extracted", body: "Text has been copied to clipboard: \(summary)")
                }
                
                // Auto-paste if enabled
                if PreferencesManager.shared.autoPaste {
                    simulatePaste()
                }
            } catch AIServiceError.notConfigured {
                showNotification(title: "Configuration Required", body: "Please configure the AI service in settings.")
                showSettings()
            } catch AIServiceError.rateLimitExceeded {
                showNotification(title: "Rate Limit Exceeded", body: "The AI service rate limit has been exceeded. Please try again later.")
            } catch {
                showNotification(title: "Error", body: "Failed to extract text: \(error.localizedDescription)")
            }
        }
    }
    
    /// Show a notification
    /// - Parameters:
    ///   - title: The notification title
    ///   - body: The notification body
    private func showNotification(title: String, body: String) {
        guard PreferencesManager.shared.showNotifications else {
            return
        }
        
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    /// Simulate a paste operation
    private func simulatePaste() {
        // Create a paste keyboard event
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Command+V (paste)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyDown?.flags = .maskCommand
        
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand
        
        // Post the events
        keyDown?.post(tap: .cgAnnotatedSessionEventTap)
        keyUp?.post(tap: .cgAnnotatedSessionEventTap)
    }
    
    /// Show the settings window
    private func showSettings() {
        // Open System Preferences and select our preference pane
        let prefPaneURL = URL(fileURLWithPath: "/System/Library/PreferencePanes/Profiles.prefPane")
        NSWorkspace.shared.open(prefPaneURL)
    }
    
    /// Set up the main window if needed
    private func setupMainWindow() {
        // For now, we don't need a main window as the app operates in the background
        // This would be implemented if we need a UI for the main application
    }
    
    /// Application will terminate
    /// - Parameter notification: The notification
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up
        NSAppleEventManager.shared().removeEventHandler(
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
}