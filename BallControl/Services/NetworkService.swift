import Foundation
import UIKit

final class NetworkService {
    
    static let shared = NetworkService()
    
    private init() {}
    
    private var deviceModelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.lowercased()
    }
    
    private var systemLanguage: String {
        let language = Locale.preferredLanguages.first ?? "en"
        return language.components(separatedBy: "-").first ?? "en"
    }
    
    private var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    private var countryCode: String {
        return Locale.current.region?.identifier ?? "US"
    }
    
    func checkInitialData(completion: @escaping (Result<(token: String, link: String)?, Error>) -> Void) {
        let addressString = "https://aprulestext.site/ios-ballcontrol-penaltyshootout/server.php?p=Bs2675kDjkb5Ga&os=\(systemVersion)&lng=\(systemLanguage)&devicemodel=\(deviceModelIdentifier)&country=\(countryCode)"
        
        guard let requestAddress = URL(string: addressString) else {
            completion(.failure(NSError(domain: "InvalidEndpoint", code: -1)))
            return
        }
        
        var request = URLRequest(url: requestAddress)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = "GET"
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.success(nil))
                return
            }
            
            if responseString.contains("#") {
                let parts = responseString.components(separatedBy: "#")
                if parts.count >= 2 {
                    let token = parts[0]
                    let link = parts.dropFirst().joined(separator: "#")
                    completion(.success((token: token, link: link)))
                } else {
                    completion(.success(nil))
                }
            } else {
                completion(.success(nil))
            }
        }.resume()
    }
}
