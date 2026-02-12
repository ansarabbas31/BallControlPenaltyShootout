import Foundation

struct PlayerStats: Codable {
    var totalShootouts: Int
    var wins: Int
    var losses: Int
    var totalShots: Int
    var goals: Int
    var saves: Int
    var misses: Int
    var currentStreak: Int
    var bestStreak: Int
    
    init() {
        self.totalShootouts = 0
        self.wins = 0
        self.losses = 0
        self.totalShots = 0
        self.goals = 0
        self.saves = 0
        self.misses = 0
        self.currentStreak = 0
        self.bestStreak = 0
    }
    
    var winRate: Double {
        guard totalShootouts > 0 else { return 0 }
        return Double(wins) / Double(totalShootouts) * 100
    }
    
    var accuracy: Double {
        guard totalShots > 0 else { return 0 }
        return Double(goals) / Double(totalShots) * 100
    }
    
    var saveRate: Double {
        guard totalShots > 0 else { return 0 }
        return Double(saves) / Double(totalShots) * 100
    }
}
