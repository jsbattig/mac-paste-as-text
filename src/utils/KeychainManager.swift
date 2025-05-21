import Foundation
import Security

/// Manager for secure storage of API keys in the Keychain
class KeychainManager {
    /// Shared instance (singleton)
    static let shared = KeychainManager()
    
    /// Service name for Keychain items
    private let serviceName = "com.pasteAsText.apiKeys"
    
    /// Private initializer for singleton
    private init() {}
    
    /// Save an API key to the Keychain
    /// - Parameters:
    ///   - apiKey: The API key to save
    ///   - serviceType: The service type (e.g., "gemini", "openai")
    /// - Returns: True if successful
    @discardableResult
    func saveAPIKey(_ apiKey: String, forServiceType serviceType: String) -> Bool {
        // Delete existing key if it exists
        deleteAPIKey(forServiceType: serviceType)
        
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: serviceType,
            kSecValueData as String: apiKey.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Add item to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    /// Get an API key from the Keychain
    /// - Parameter serviceType: The service type (e.g., "gemini", "openai")
    /// - Returns: The API key, or nil if not found
    func getAPIKey(forServiceType serviceType: String) -> String? {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: serviceType,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Query Keychain
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        // Check result
        if status == errSecSuccess, let data = result as? Data, let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }
        
        return nil
    }
    
    /// Delete an API key from the Keychain
    /// - Parameter serviceType: The service type (e.g., "gemini", "openai")
    /// - Returns: True if successful
    @discardableResult
    func deleteAPIKey(forServiceType serviceType: String) -> Bool {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: serviceType
        ]
        
        // Delete item from Keychain
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Check if an API key exists in the Keychain
    /// - Parameter serviceType: The service type (e.g., "gemini", "openai")
    /// - Returns: True if the API key exists
    func hasAPIKey(forServiceType serviceType: String) -> Bool {
        return getAPIKey(forServiceType: serviceType) != nil
    }
    
    /// Delete all API keys from the Keychain
    /// - Returns: True if successful
    @discardableResult
    func deleteAllAPIKeys() -> Bool {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        
        // Delete items from Keychain
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Get all service types with API keys
    /// - Returns: Array of service types
    func getAllServiceTypes() -> [String] {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        // Query Keychain
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        // Check result
        if status == errSecSuccess, let items = result as? [[String: Any]] {
            // Extract service types
            return items.compactMap { item in
                item[kSecAttrAccount as String] as? String
            }
        }
        
        return []
    }
    
    /// Migrate API keys from UserDefaults to Keychain
    /// - Parameter userDefaults: The UserDefaults instance
    /// - Returns: True if migration was successful
    @discardableResult
    func migrateAPIKeysFromUserDefaults(_ userDefaults: UserDefaults = .standard) -> Bool {
        // Check if migration has already been performed
        if userDefaults.bool(forKey: "apiKeysMigrated") {
            return true
        }
        
        // Get API keys from UserDefaults
        let serviceTypes = ["gemini", "openai", "anthropic"]
        var migrationSuccessful = true
        
        for serviceType in serviceTypes {
            let key = "apiKey_\(serviceType)"
            if let apiKey = userDefaults.string(forKey: key), !apiKey.isEmpty {
                // Save API key to Keychain
                let success = saveAPIKey(apiKey, forServiceType: serviceType)
                if success {
                    // Remove API key from UserDefaults
                    userDefaults.removeObject(forKey: key)
                } else {
                    migrationSuccessful = false
                }
            }
        }
        
        // Mark migration as complete
        if migrationSuccessful {
            userDefaults.set(true, forKey: "apiKeysMigrated")
        }
        
        return migrationSuccessful
    }
}