import Foundation

struct HowToPlayItem {
    let icon: String
    let title: String
    let detail: String
}

final class SettingsViewModel {
    
    private let dataManager = DataManager.shared
    
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var totalShootouts: Int {
        return dataManager.shootouts.count
    }
    
    let howToPlayItems: [HowToPlayItem] = [
        HowToPlayItem(
            icon: "hand.draw",
            title: "Shooting",
            detail: "Touch the ball and swipe toward the goal. The direction of the swipe determines where the ball goes. Aim for the corners to make it harder for the keeper!"
        ),
        HowToPlayItem(
            icon: "hand.tap",
            title: "Goalkeeping",
            detail: "When the opponent shoots, tap one of the highlighted zones in the goal to dive there. Try to predict where the shot will go!"
        ),
        HowToPlayItem(
            icon: "arrow.triangle.2.circlepath",
            title: "Rounds",
            detail: "Each round you shoot first, then defend. The shootout lasts 5 rounds. If the score is tied, sudden death rounds are played."
        ),
        HowToPlayItem(
            icon: "star.circle",
            title: "Zones",
            detail: "The goal is divided into 6 zones: top-left, top-center, top-right, bottom-left, bottom-center, bottom-right. Swipe steeply upward to aim high, or more forward to aim low."
        ),
        HowToPlayItem(
            icon: "gauge.medium",
            title: "Difficulty",
            detail: "Choose Easy, Medium, or Hard before starting. Higher difficulty means the CPU goalkeeper saves more often and the CPU striker aims for the corners."
        )
    ]
    
    func resetAllData() {
        dataManager.resetAllData()
    }
}
