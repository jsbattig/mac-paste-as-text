import Cocoa
import PreferencePanes

/// Preference pane for the "Paste as Text" extension
@objc(PasteAsTextPreferencePane)
class PasteAsTextPreferencePane: NSPreferencePane {
    // MARK: - Outlets
    
    /// Popup button for selecting the AI service
    @IBOutlet weak var servicePopup: NSPopUpButton!
    
    /// Secure text field for the API key
    @IBOutlet weak var apiKeyField: NSSecureTextField!
    
    /// Popup button for selecting the language
    @IBOutlet weak var languagePopup: NSPopUpButton!
    
    /// Checkbox for auto-paste
    @IBOutlet weak var autoPasteCheckbox: NSButton!
    
    /// Checkbox for notifications
    @IBOutlet weak var notificationsCheckbox: NSButton!
    
    /// Slider for confidence threshold
    @IBOutlet weak var confidenceSlider: NSSlider!
    
    /// Label for confidence threshold value
    @IBOutlet weak var confidenceLabel: NSTextField!
    
    /// Stepper for max retries
    @IBOutlet weak var retriesStepper: NSStepper!
    
    /// Text field for max retries
    @IBOutlet weak var retriesField: NSTextField!
    
    // MARK: - Lifecycle
    
    /// Main view did load
    override func mainViewDidLoad() {
        super.mainViewDidLoad()
        
        // Setup service popup
        setupServicePopup()
        
        // Load API key
        loadAPIKey()
        
        // Setup language popup
        setupLanguagePopup()
        
        // Setup checkboxes
        setupCheckboxes()
        
        // Setup advanced controls
        setupAdvancedControls()
    }
    
    // MARK: - Setup
    
    /// Setup the service popup
    private func setupServicePopup() {
        servicePopup.removeAllItems()
        
        // Add all available service types
        for serviceType in AIServiceType.allCases {
            servicePopup.addItem(withTitle: serviceType.displayName)
        }
        
        // Select current service
        let currentService = PreferencesManager.shared.selectedAIService
        servicePopup.selectItem(withTitle: currentService.displayName)
    }
    
    /// Load the API key for the selected service
    private func loadAPIKey() {
        guard let title = servicePopup.selectedItem?.title,
              let serviceType = AIServiceType.allCases.first(where: { $0.displayName == title }) else {
            return
        }
        
        do {
            if let apiKey = try KeychainManager.shared.getAPIKey(for: serviceType) {
                apiKeyField.stringValue = apiKey
            } else {
                apiKeyField.stringValue = ""
            }
        } catch {
            apiKeyField.stringValue = ""
            print("Failed to load API key: \(error)")
        }
    }
    
    /// Setup the language popup
    private func setupLanguagePopup() {
        languagePopup.removeAllItems()
        
        // Add supported languages
        let languages = [
            ("English", "en"),
            ("Spanish", "es"),
            ("French", "fr"),
            ("German", "de"),
            ("Chinese", "zh"),
            ("Japanese", "ja")
        ]
        
        for (name, code) in languages {
            languagePopup.addItem(withTitle: name)
            languagePopup.lastItem?.representedObject = code
        }
        
        // Select current language
        let currentLanguage = PreferencesManager.shared.languagePreference
        for (index, (_, code)) in languages.enumerated() {
            if code == currentLanguage {
                languagePopup.selectItem(at: index)
                break
            }
        }
    }
    
    /// Setup the checkboxes
    private func setupCheckboxes() {
        autoPasteCheckbox.state = PreferencesManager.shared.autoPaste ? .on : .off
        notificationsCheckbox.state = PreferencesManager.shared.showNotifications ? .on : .off
    }
    
    /// Setup the advanced controls
    private func setupAdvancedControls() {
        // Confidence threshold
        let confidence = PreferencesManager.shared.confidenceThreshold
        confidenceSlider.doubleValue = confidence
        updateConfidenceLabel()
        
        // Max retries
        let retries = PreferencesManager.shared.maxRetries
        retriesStepper.integerValue = retries
        retriesField.integerValue = retries
    }
    
    /// Update the confidence label
    private func updateConfidenceLabel() {
        let confidence = confidenceSlider.doubleValue
        let percentage = Int(confidence * 100)
        confidenceLabel.stringValue = "\(percentage)%"
    }
    
    // MARK: - Actions
    
    /// Service selection changed
    @IBAction func serviceChanged(_ sender: NSPopUpButton) {
        guard let title = sender.selectedItem?.title,
              let serviceType = AIServiceType.allCases.first(where: { $0.displayName == title }) else {
            return
        }
        
        // Update selected service
        PreferencesManager.shared.selectedAIService = serviceType
        
        // Update API key field
        loadAPIKey()
    }
    
    /// Save API key
    @IBAction func saveAPIKey(_ sender: Any) {
        guard let title = servicePopup.selectedItem?.title,
              let serviceType = AIServiceType.allCases.first(where: { $0.displayName == title }) else {
            return
        }
        
        let apiKey = apiKeyField.stringValue
        
        do {
            try KeychainManager.shared.saveAPIKey(apiKey, for: serviceType)
            
            // Configure the service
            try AIServiceManager.shared.configureService(serviceType, withAPIKey: apiKey)
            
            // Show success message
            let alert = NSAlert()
            alert.messageText = "API Key Saved"
            alert.informativeText = "Your API key has been saved successfully."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } catch {
            // Show error
            let alert = NSAlert()
            alert.messageText = "Failed to Save API Key"
            alert.informativeText = "There was an error saving your API key: \(error.localizedDescription)"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    /// Language selection changed
    @IBAction func languageChanged(_ sender: NSPopUpButton) {
        guard let code = sender.selectedItem?.representedObject as? String else {
            return
        }
        
        PreferencesManager.shared.languagePreference = code
    }
    
    /// Auto-paste checkbox changed
    @IBAction func autoPasteChanged(_ sender: NSButton) {
        PreferencesManager.shared.autoPaste = (sender.state == .on)
    }
    
    /// Notifications checkbox changed
    @IBAction func notificationsChanged(_ sender: NSButton) {
        PreferencesManager.shared.showNotifications = (sender.state == .on)
    }
    
    /// Confidence slider changed
    @IBAction func confidenceChanged(_ sender: NSSlider) {
        PreferencesManager.shared.confidenceThreshold = sender.doubleValue
        updateConfidenceLabel()
    }
    
    /// Max retries stepper changed
    @IBAction func retriesChanged(_ sender: NSStepper) {
        let value = sender.integerValue
        PreferencesManager.shared.maxRetries = value
        retriesField.integerValue = value
    }
    
    /// Max retries field changed
    @IBAction func retriesFieldChanged(_ sender: NSTextField) {
        let value = sender.integerValue
        PreferencesManager.shared.maxRetries = value
        retriesStepper.integerValue = value
    }
    
    /// Reset to defaults button clicked
    @IBAction func resetToDefaults(_ sender: Any) {
        // Show confirmation dialog
        let alert = NSAlert()
        alert.messageText = "Reset to Defaults"
        alert.informativeText = "Are you sure you want to reset all settings to their default values? This will not delete your API keys."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Reset preferences
            PreferencesManager.shared.resetToDefaults()
            
            // Update UI
            setupServicePopup()
            setupLanguagePopup()
            setupCheckboxes()
            setupAdvancedControls()
        }
    }
}