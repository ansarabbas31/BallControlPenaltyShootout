import Foundation

final class DataManager {
    
    static let shared = DataManager()
    
    private let shootoutsKey = "saved_shootouts_v3"
    private let statsKey = "saved_player_stats_v3"
    
    private init() {}
    
    var shootouts: [PenaltyShootout] {
        get {
            guard let data = UserDefaults.standard.data(forKey: shootoutsKey),
                  let decoded = try? JSONDecoder().decode([PenaltyShootout].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: shootoutsKey)
            }
        }
    }
    
    var playerStats: PlayerStats {
        get {
            guard let data = UserDefaults.standard.data(forKey: statsKey),
                  let decoded = try? JSONDecoder().decode(PlayerStats.self, from: data) else {
                return PlayerStats()
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: statsKey)
            }
        }
    }
    
    func addShootout(_ shootout: PenaltyShootout) {
        var current = shootouts
        current.insert(shootout, at: 0)
        shootouts = current
    }
    
    func updatePlayerStats(with shootout: PenaltyShootout) {
        var stats = playerStats
        stats.totalShootouts += 1
        
        if shootout.playerScore > shootout.opponentScore {
            stats.wins += 1
            stats.currentStreak += 1
            stats.bestStreak = max(stats.bestStreak, stats.currentStreak)
        } else {
            stats.losses += 1
            stats.currentStreak = 0
        }
        
        for shot in shootout.playerShots {
            stats.totalShots += 1
            if shot.result == .goal { stats.goals += 1 }
            if shot.result == .missed { stats.misses += 1 }
        }
        
        for shot in shootout.opponentShots {
            if shot.result == .saved { stats.saves += 1 }
        }
        
        playerStats = stats
    }
    
    func getZoneStatistics() -> [ZoneStatistics] {
        var zoneStats = ShotZone.allCases.map { ZoneStatistics(zone: $0) }
        
        for shootout in shootouts {
            for shot in shootout.playerShots {
                if let idx = zoneStats.firstIndex(where: { $0.zone == shot.targetZone }) {
                    zoneStats[idx].attempts += 1
                    switch shot.result {
                    case .goal: zoneStats[idx].goals += 1
                    case .saved: zoneStats[idx].saved += 1
                    case .missed: zoneStats[idx].missed += 1
                    }
                }
            }
        }
        
        return zoneStats
    }
    
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: shootoutsKey)
        UserDefaults.standard.removeObject(forKey: statsKey)
    }
}
