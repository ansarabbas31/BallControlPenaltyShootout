import Foundation

final class StorageService {
    
    static let shared = StorageService()
    
    private let defaults = UserDefaults.standard
    private let tokenKey = "app_secure_token"
    private let linkKey = "app_content_link"
    private let launchKey = "app_first_launch_with_token"
    
    private init() {}
    
    var token: String? {
        get { defaults.string(forKey: tokenKey) }
        set { defaults.set(newValue, forKey: tokenKey) }
    }
    
    var contentLink: String? {
        get { defaults.string(forKey: linkKey) }
        set { defaults.set(newValue, forKey: linkKey) }
    }
    
    var isFirstLaunchWithToken: Bool {
        get { !defaults.bool(forKey: launchKey) }
        set { defaults.set(!newValue, forKey: launchKey) }
    }
    
    func saveCredentials(token: String, link: String) {
        self.token = token
        self.contentLink = link
    }
    
    func clearAll() {
        defaults.removeObject(forKey: tokenKey)
        defaults.removeObject(forKey: linkKey)
        defaults.removeObject(forKey: launchKey)
    }
    
    var hasStoredToken: Bool {
        return token != nil && contentLink != nil
    }
}
