import Foundation

/// Manager for user preferences
class PreferencesManager {
    /// Shared instance (singleton)
    static let shared = PreferencesManager()
    
    /// UserDefaults suite
    private let defaults = UserDefaults.standard
    
    /// Keys for preferences
    enum PreferenceKey: String, CaseIterable {
        case isFirstLaunch
        case selectedServiceType
        case isClipboardMonitoringEnabled
        case isAutomaticExtractionEnabled
        case isAutoPasteEnabled
        case isNotificationsEnabled
        case confidenceThreshold
        case maxRetries
        case selectedLanguage
    }
    
    /// Private initializer for singleton
    private init() {
        // Register default values
        registerDefaults()
    }
    
    /// Register default values
    private func registerDefaults() {
        let defaultValues: [String: Any] = [
            PreferenceKey.isFirstLaunch.rawValue: true,
            PreferenceKey.selectedServiceType.rawValue: "gemini",
            PreferenceKey.isClipboardMonitoringEnabled.rawValue: false,
            PreferenceKey.isAutomaticExtractionEnabled.rawValue: false,
            PreferenceKey.isAutoPasteEnabled.rawValue: true,
            PreferenceKey.isNotificationsEnabled.rawValue: true,
            PreferenceKey.confidenceThreshold.rawValue: 0.0,
            PreferenceKey.maxRetries.rawValue: 3,
            PreferenceKey.selectedLanguage.rawValue: "en"
        ]
        
        defaults.register(defaults: defaultValues)
    }
    
    /// Save preferences
    func savePreferences() {
        defaults.synchronize()
    }
    
    /// Reset preferences to defaults
    func resetToDefaults() {
        for key in PreferenceKey.allCases {
            defaults.removeObject(forKey: key.rawValue)
        }
        
        registerDefaults()
    }
    
    // MARK: - First Launch
    
    /// Whether this is the first launch of the application
    var isFirstLaunch: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.isFirstLaunch.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.isFirstLaunch.rawValue)
        }
    }
    
    // MARK: - Service Type
    
    /// The selected service type
    var selectedServiceType: String {
        get {
            return defaults.string(forKey: PreferenceKey.selectedServiceType.rawValue) ?? "gemini"
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.selectedServiceType.rawValue)
        }
    }
    
    // MARK: - Clipboard Monitoring
    
    /// Whether clipboard monitoring is enabled
    var isClipboardMonitoringEnabled: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.isClipboardMonitoringEnabled.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.isClipboardMonitoringEnabled.rawValue)
        }
    }
    
    // MARK: - Automatic Extraction
    
    /// Whether automatic extraction is enabled
    var isAutomaticExtractionEnabled: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.isAutomaticExtractionEnabled.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.isAutomaticExtractionEnabled.rawValue)
        }
    }
    
    // MARK: - Auto Paste
    
    /// Whether auto paste is enabled
    var isAutoPasteEnabled: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.isAutoPasteEnabled.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.isAutoPasteEnabled.rawValue)
        }
    }
    
    // MARK: - Notifications
    
    /// Whether notifications are enabled
    var isNotificationsEnabled: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.isNotificationsEnabled.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.isNotificationsEnabled.rawValue)
        }
    }
    
    // MARK: - Confidence Threshold
    
    /// The confidence threshold for text extraction
    var confidenceThreshold: Double {
        get {
            return defaults.double(forKey: PreferenceKey.confidenceThreshold.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.confidenceThreshold.rawValue)
        }
    }
    
    // MARK: - Max Retries
    
    /// The maximum number of retries for text extraction
    var maxRetries: Int {
        get {
            return defaults.integer(forKey: PreferenceKey.maxRetries.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.maxRetries.rawValue)
        }
    }
    
    // MARK: - Selected Language
    
    /// The selected language for text extraction
    var selectedLanguage: String {
        get {
            return defaults.string(forKey: PreferenceKey.selectedLanguage.rawValue) ?? "en"
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.selectedLanguage.rawValue)
        }
    }
}