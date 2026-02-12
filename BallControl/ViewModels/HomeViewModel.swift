import Foundation

final class HomeViewModel {
    
    private let dataManager = DataManager.shared
    
    var playerStats: PlayerStats {
        return dataManager.playerStats
    }
    
    var recentShootouts: [PenaltyShootout] {
        return Array(dataManager.shootouts.prefix(10))
    }
    
    var totalShootouts: Int {
        return dataManager.shootouts.count
    }
}
