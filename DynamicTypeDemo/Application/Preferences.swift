//
//  Preferences.swift
//  DynamicTypeDemo
//
//  Created by Daisy Ramos on 2/1/21.
//

import UIKit

final class Preferences {
    
    private enum Key: String {
        case userSelectedContentSizeCategory
        case shouldUseUserSelectedContentSizeCategory
    }

    private let userDefaults: UserDefaults
    private let notificationCenter = NotificationCenter.default
    
    /// A content size category that the user has selected.
    var userSelectedContentSizeCategory: UIContentSizeCategory? {
        get {
            return userDefaults.codable(forKey: Key.userSelectedContentSizeCategory.rawValue)
        }
        set {
            userDefaults.setCodable(newValue, forKey: Key.userSelectedContentSizeCategory.rawValue)
            notificationCenter.post(name: .userSelectedContentSizeCategoryDidChangeNotification, object: nil)
        }
    }
    
    /// Whether to use the user-selected content size category or the system one.
    var shouldUseUserSelectedContentSizeCategory: Bool {
        get {
            return userDefaults.bool(forKey: Key.shouldUseUserSelectedContentSizeCategory.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.shouldUseUserSelectedContentSizeCategory.rawValue)
        }
    }
    
    /// Initializes preferences with the specified user defaults.
    ///
    /// - Parameter userDefaults: The user defaults to use when storing and retrieving preferences. Defaults to `.standard`.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        registerDefaults()
    }
    
    private func registerDefaults() {
        userDefaults.register(defaults: [
            Notification.Name.userSelectedContentSizeCategoryDidChangeNotification.rawValue: UIContentSizeCategory.large.rawValue
        ])
    }
}

extension Notification.Name {
    
    static let userSelectedContentSizeCategoryDidChangeNotification = Notification.Name(rawValue: "userSelectedContentSizeCategoryDidChangeNotification")
}

extension UIContentSizeCategory: Codable {}

private extension UserDefaults {
    
    func codable<T: Codable>(forKey key: String) -> T? {
        do {
            guard let data = self.data(forKey: key) else {
                return nil
            }

            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
    
    func setCodable<T: Codable>(_ value: T?, forKey key: String) {
        if let value = value {
            do {
                let data = try JSONEncoder().encode(value)
                
                set(data, forKey: key)
            } catch {
                return
            }
        } else {
            set(value, forKey: key)
        }
    }
}
