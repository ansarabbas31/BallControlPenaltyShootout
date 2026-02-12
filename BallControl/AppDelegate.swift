import UIKit
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var shouldRequestReview = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let storage = StorageService.shared
        
        if storage.hasStoredToken {
            shouldRequestReview = storage.isFirstLaunchWithToken
            storage.isFirstLaunchWithToken = false
            showContentDisplay(address: storage.contentLink ?? "")
            
            if shouldRequestReview {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.requestAppReview()
                }
            }
        } else {
            showLoadingScreen()
            checkServerData()
        }
        
        return true
    }
    
    private func showLoadingScreen() {
        let loadingVC = LoadingViewController()
        window?.rootViewController = loadingVC
    }
    
    private func showContentDisplay(address: String) {
        let contentVC = ContentDisplayController(address: address)
        window?.rootViewController = contentVC
    }
    
    private func showMainApp() {
        let tabBar = MainTabBarController()
        window?.rootViewController = tabBar
    }
    
    private func checkServerData() {
        NetworkService.shared.checkInitialData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let credentials = data {
                        StorageService.shared.saveCredentials(token: credentials.token, link: credentials.link)
                        self?.showContentDisplay(address: credentials.link)
                    } else {
                        self?.showMainApp()
                    }
                case .failure:
                    self?.showMainApp()
                }
            }
        }
    }
    
    private func requestAppReview() {
        if let scene = window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootVC = window?.rootViewController {
            if rootVC is ContentDisplayController {
                return .all
            }
        }
        return .portrait
    }
}
