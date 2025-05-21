import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Status bar item
    private var statusItem: NSStatusItem?
    
    // Main window controller
    private var mainWindowController: NSWindowController?
    
    // Preferences window controller
    private var preferencesWindowController: NSWindowController?
    
    // Service manager
    private var serviceManager: AIServiceManager?
    
    // Clipboard manager
    private var clipboardManager: ClipboardManager?
    
    // Preferences manager
    private var preferencesManager: PreferencesManager?
    
    // URL scheme handler
    private var urlSchemeHandler: URLSchemeHandler?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize managers
        initializeManagers()
        
        // Set up status bar
        setupStatusBar()
        
        // Register for URL scheme
        registerURLScheme()
        
        // Check for first launch
        checkFirstLaunch()
        
        // Start clipboard monitoring if enabled
        startClipboardMonitoringIfEnabled()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Stop clipboard monitoring
        clipboardManager?.stopMonitoring()
        
        // Save preferences
        preferencesManager?.savePreferences()
    }
    
    // MARK: - Initialization
    
    private func initializeManagers() {
        // Initialize service manager
        serviceManager = AIServiceManager.shared
        
        // Initialize clipboard manager
        clipboardManager = ClipboardManager.shared
        
        // Initialize preferences manager
        preferencesManager = PreferencesManager.shared
        
        // Initialize URL scheme handler
        urlSchemeHandler = URLSchemeHandler(delegate: self)
    }
    
    // MARK: - Status Bar
    
    private func setupStatusBar() {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            // Set status bar icon
            button.image = NSImage(named: "StatusBarIcon")
            button.image?.isTemplate = true
            
            // Set status bar menu
            let menu = createStatusBarMenu()
            statusItem?.menu = menu
        }
    }
    
    private func createStatusBarMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Extract Text from Clipboard
        menu.addItem(NSMenuItem(title: "Extract Text from Clipboard", action: #selector(extractTextFromClipboard), keyEquivalent: "e"))
        
        // Separator
        menu.addItem(NSMenuItem.separator())
        
        // Preferences
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        
        // Separator
        menu.addItem(NSMenuItem.separator())
        
        // About
        menu.addItem(NSMenuItem(title: "About Paste as Text", action: #selector(showAbout), keyEquivalent: ""))
        
        // Quit
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        return menu
    }
    
    // MARK: - URL Scheme
    
    private func registerURLScheme() {
        // Register for URL scheme events
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    @objc private func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        // Extract URL from event
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            return
        }
        
        // Handle URL
        urlSchemeHandler?.handleURL(url)
    }
    
    // MARK: - First Launch
    
    private func checkFirstLaunch() {
        if preferencesManager?.isFirstLaunch == true {
            // Show welcome window
            showWelcomeWindow()
            
            // Set first launch flag to false
            preferencesManager?.isFirstLaunch = false
        }
    }
    
    private func showWelcomeWindow() {
        // Create and show welcome window
        let welcomeWindowController = WelcomeWindowController()
        welcomeWindowController.showWindow(nil)
        
        // Keep a reference to the window controller
        mainWindowController = welcomeWindowController
    }
    
    // MARK: - Clipboard Monitoring
    
    private func startClipboardMonitoringIfEnabled() {
        if preferencesManager?.isClipboardMonitoringEnabled == true {
            clipboardManager?.startMonitoring(delegate: self)
        }
    }
    
    // MARK: - Actions
    
    @objc private func extractTextFromClipboard() {
        // Check if clipboard contains an image
        guard let image = clipboardManager?.getImageFromClipboard() else {
            showNotification(title: "No Image Found", message: "The clipboard does not contain an image.")
            return
        }
        
        // Extract text from image
        extractTextFromImage(image)
    }
    
    @objc private func showPreferences() {
        // Create preferences window if needed
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController()
        }
        
        // Show preferences window
        preferencesWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func showAbout() {
        // Show about panel
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // MARK: - Text Extraction
    
    private func extractTextFromImage(_ image: NSImage) {
        // Show progress indicator
        showProgressIndicator()
        
        // Check if service manager is configured
        guard serviceManager?.isSelectedAdapterConfigured() == true else {
            hideProgressIndicator()
            showNotification(title: "Service Not Configured", message: "Please configure an AI service in Preferences.")
            showPreferences()
            return
        }
        
        // Extract text from image
        Task {
            do {
                // Extract text
                let extractedText = try await serviceManager?.extractTextFromImage(image)
                
                // Hide progress indicator
                hideProgressIndicator()
                
                // Handle extracted text
                handleExtractedText(extractedText)
            } catch {
                // Hide progress indicator
                hideProgressIndicator()
                
                // Show error
                showNotification(title: "Text Extraction Failed", message: error.localizedDescription)
            }
        }
    }
    
    private func handleExtractedText(_ extractedText: ExtractedText?) {
        guard let extractedText = extractedText else {
            showNotification(title: "Text Extraction Failed", message: "No text was extracted.")
            return
        }
        
        // Copy text to clipboard
        clipboardManager?.writeTextToClipboard(extractedText.text)
        
        // Show notification
        showNotification(title: "Text Extracted", message: "Text has been copied to clipboard.")
        
        // Auto-paste if enabled
        if preferencesManager?.isAutoPasteEnabled == true {
            autoPasteText()
        }
    }
    
    private func autoPasteText() {
        // Simulate Cmd+V keystroke
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Key down for Cmd+V
        let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyDownEvent?.flags = .maskCommand
        keyDownEvent?.post(tap: .cghidEventTap)
        
        // Key up for Cmd+V
        let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUpEvent?.flags = .maskCommand
        keyUpEvent?.post(tap: .cghidEventTap)
    }
    
    // MARK: - Progress Indicator
    
    private func showProgressIndicator() {
        // Show progress indicator in status bar
        if let button = statusItem?.button {
            button.image = NSImage(named: "StatusBarIconProgress")
        }
    }
    
    private func hideProgressIndicator() {
        // Hide progress indicator in status bar
        if let button = statusItem?.button {
            button.image = NSImage(named: "StatusBarIcon")
        }
    }
    
    // MARK: - Notifications
    
    private func showNotification(title: String, message: String) {
        // Check if notifications are enabled
        guard preferencesManager?.isNotificationsEnabled == true else {
            return
        }
        
        // Create notification
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.soundName = NSUserNotificationDefaultSoundName
        
        // Show notification
        NSUserNotificationCenter.default.deliver(notification)
    }
}

// MARK: - ClipboardManagerDelegate

extension AppDelegate: ClipboardManagerDelegate {
    func clipboardDidChangeWithImage(_ image: NSImage) {
        // Check if automatic extraction is enabled
        guard preferencesManager?.isAutomaticExtractionEnabled == true else {
            return
        }
        
        // Extract text from image
        extractTextFromImage(image)
    }
}

// MARK: - URLSchemeHandlerDelegate

extension AppDelegate: URLSchemeHandlerDelegate {
    func handleExtractTextCommand(fromURL url: URL) {
        // Extract text from clipboard
        extractTextFromClipboard()
    }
}

// MARK: - Supporting Types

protocol ClipboardManagerDelegate: AnyObject {
    func clipboardDidChangeWithImage(_ image: NSImage)
}

protocol URLSchemeHandlerDelegate: AnyObject {
    func handleExtractTextCommand(fromURL url: URL)
}

class URLSchemeHandler {
    weak var delegate: URLSchemeHandlerDelegate?
    
    init(delegate: URLSchemeHandlerDelegate) {
        self.delegate = delegate
    }
    
    func handleURL(_ url: URL) {
        // Check if URL is for our scheme
        guard url.scheme == "pasteastext" else {
            return
        }
        
        // Handle different commands
        switch url.host {
        case "extract":
            delegate?.handleExtractTextCommand(fromURL: url)
        default:
            break
        }
    }
}

class WelcomeWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Configure window
        window?.title = "Welcome to Paste as Text"
        window?.center()
        window?.isReleasedWhenClosed = false
    }
}

class PreferencesWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Configure window
        window?.title = "Paste as Text Preferences"
        window?.center()
        window?.isReleasedWhenClosed = false
    }
}