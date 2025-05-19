import Foundation

/// Manager for user preferences
class PreferencesManager {
    /// Shared instance (singleton)
    static let shared = PreferencesManager()
    
    /// UserDefaults instance for storing preferences
    private let defaults = UserDefaults.standard
    
    /// Keys for preferences
    enum PreferenceKey: String {
        case selectedAIService
        case languagePreference
        case autoPaste
        case showNotifications
        case confidenceThreshold
        case maxRetries
        case timeout
        case debugLogging
    }
    
    /// Private initializer for singleton
    private init() {
        // Register default values
        let defaultValues: [String: Any] = [
            PreferenceKey.selectedAIService.rawValue: AIServiceType.gemini.rawValue,
            PreferenceKey.languagePreference.rawValue: "en",
            PreferenceKey.autoPaste.rawValue: true,
            PreferenceKey.showNotifications.rawValue: true,
            PreferenceKey.confidenceThreshold.rawValue: 0.0,
            PreferenceKey.maxRetries.rawValue: 3,
            PreferenceKey.timeout.rawValue: 30.0,
            PreferenceKey.debugLogging.rawValue: false
        ]
        
        defaults.register(defaults: defaultValues)
    }
    
    /// Selected AI service
    var selectedAIService: AIServiceType {
        get {
            guard let value = defaults.string(forKey: PreferenceKey.selectedAIService.rawValue),
                  let serviceType = AIServiceType(rawValue: value) else {
                return .gemini // Default service
            }
            return serviceType
        }
        set {
            defaults.set(newValue.rawValue, forKey: PreferenceKey.selectedAIService.rawValue)
        }
    }
    
    /// Preferred language for OCR
    var languagePreference: String {
        get {
            return defaults.string(forKey: PreferenceKey.languagePreference.rawValue) ?? "en"
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.languagePreference.rawValue)
        }
    }
    
    /// Whether to automatically paste the extracted text
    var autoPaste: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.autoPaste.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.autoPaste.rawValue)
        }
    }
    
    /// Whether to show notifications
    var showNotifications: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.showNotifications.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.showNotifications.rawValue)
        }
    }
    
    /// Confidence threshold for OCR (0.0 to 1.0)
    var confidenceThreshold: Double {
        get {
            return defaults.double(forKey: PreferenceKey.confidenceThreshold.rawValue)
        }
        set {
            // Ensure value is between 0.0 and 1.0
            let clampedValue = max(0.0, min(1.0, newValue))
            defaults.set(clampedValue, forKey: PreferenceKey.confidenceThreshold.rawValue)
        }
    }
    
    /// Maximum number of retries for API calls
    var maxRetries: Int {
        get {
            return defaults.integer(forKey: PreferenceKey.maxRetries.rawValue)
        }
        set {
            // Ensure value is at least 0
            let clampedValue = max(0, newValue)
            defaults.set(clampedValue, forKey: PreferenceKey.maxRetries.rawValue)
        }
    }
    
    /// Timeout for API calls in seconds
    var timeout: TimeInterval {
        get {
            return defaults.double(forKey: PreferenceKey.timeout.rawValue)
        }
        set {
            // Ensure value is at least 1.0
            let clampedValue = max(1.0, newValue)
            defaults.set(clampedValue, forKey: PreferenceKey.timeout.rawValue)
        }
    }
    
    /// Whether to enable debug logging
    var debugLogging: Bool {
        get {
            return defaults.bool(forKey: PreferenceKey.debugLogging.rawValue)
        }
        set {
            defaults.set(newValue, forKey: PreferenceKey.debugLogging.rawValue)
        }
    }
    
    /// Reset all preferences to default values
    func resetToDefaults() {
        for key in PreferenceKey.allCases {
            defaults.removeObject(forKey: key.rawValue)
        }
    }
    
    /// Get a dictionary of all preferences
    /// - Returns: Dictionary with preference keys and values
    func getAllPreferences() -> [String: Any] {
        var preferences: [String: Any] = [:]
        
        for key in PreferenceKey.allCases {
            preferences[key.rawValue] = defaults.object(forKey: key.rawValue)
        }
        
        return preferences
    }
}

/// Extension to make PreferenceKey conform to CaseIterable
extension PreferencesManager.PreferenceKey: CaseIterable {}