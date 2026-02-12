import Foundation

final class StatisticsViewModel {
    
    private let dataManager = DataManager.shared
    
    var playerStats: PlayerStats {
        return dataManager.playerStats
    }
    
    var zoneStats: [ZoneStatistics] {
        return dataManager.getZoneStatistics()
    }
    
    var shootouts: [PenaltyShootout] {
        return dataManager.shootouts
    }
    
    var completedShootouts: [PenaltyShootout] {
        return shootouts.filter { $0.status == .completed }
    }
}
