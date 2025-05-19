import Foundation
import Security

/// Manager for secure storage of API keys in the Keychain
class KeychainManager {
    /// Shared instance (singleton)
    static let shared = KeychainManager()
    
    /// Service name for Keychain entries
    private let service = "com.pasteAsText.app"
    
    /// Private initializer for singleton
    private init() {}
    
    /// Save an API key to the Keychain
    /// - Parameters:
    ///   - key: The API key to save
    ///   - serviceType: The AI service type
    /// - Throws: KeychainError if saving fails
    func saveAPIKey(_ key: String, for serviceType: AIServiceType) throws {
        let account = serviceType.rawValue
        
        // Delete any existing key
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new key
        let keyData = key.data(using: .utf8)!
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
    }
    
    /// Get an API key from the Keychain
    /// - Parameter serviceType: The AI service type
    /// - Returns: The API key if found, nil otherwise
    /// - Throws: KeychainError if reading fails
    func getAPIKey(for serviceType: AIServiceType) throws -> String? {
        let account = serviceType.rawValue
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.readFailed(status)
        }
        
        guard let data = item as? Data, let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.conversionFailed
        }
        
        return key
    }
    
    /// Delete an API key from the Keychain
    /// - Parameter serviceType: The AI service type
    /// - Throws: KeychainError if deletion fails
    func deleteAPIKey(for serviceType: AIServiceType) throws {
        let account = serviceType.rawValue
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    /// Check if an API key exists in the Keychain
    /// - Parameter serviceType: The AI service type
    /// - Returns: True if the key exists
    /// - Throws: KeychainError if checking fails
    func hasAPIKey(for serviceType: AIServiceType) throws -> Bool {
        let account = serviceType.rawValue
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: false
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound {
            return false
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.readFailed(status)
        }
        
        return true
    }
    
    /// Update an existing API key in the Keychain
    /// - Parameters:
    ///   - key: The new API key
    ///   - serviceType: The AI service type
    /// - Throws: KeychainError if updating fails
    func updateAPIKey(_ key: String, for serviceType: AIServiceType) throws {
        let account = serviceType.rawValue
        
        // Check if the key exists
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let keyData = key.data(using: .utf8)!
        let updateAttributes: [String: Any] = [
            kSecValueData as String: keyData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
        
        if status == errSecItemNotFound {
            // Key doesn't exist, save it
            try saveAPIKey(key, for: serviceType)
        } else if status != errSecSuccess {
            throw KeychainError.updateFailed(status)
        }
    }
}

/// Errors that can occur when using the Keychain
enum KeychainError: Error {
    /// Failed to save to Keychain
    case saveFailed(OSStatus)
    
    /// Failed to read from Keychain
    case readFailed(OSStatus)
    
    /// Failed to delete from Keychain
    case deleteFailed(OSStatus)
    
    /// Failed to update in Keychain
    case updateFailed(OSStatus)
    
    /// Failed to convert data
    case conversionFailed
    
    /// User-friendly error description
    var localizedDescription: String {
        switch self {
        case .saveFailed(let status):
            return "Failed to save API key to Keychain: \(status)"
        case .readFailed(let status):
            return "Failed to read API key from Keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete API key from Keychain: \(status)"
        case .updateFailed(let status):
            return "Failed to update API key in Keychain: \(status)"
        case .conversionFailed:
            return "Failed to convert API key data"
        }
    }
}