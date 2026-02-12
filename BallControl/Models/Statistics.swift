import Foundation

struct ZoneStatistics: Codable {
    var zone: ShotZone
    var attempts: Int
    var goals: Int
    var saved: Int
    var missed: Int
    
    init(zone: ShotZone) {
        self.zone = zone
        self.attempts = 0
        self.goals = 0
        self.saved = 0
        self.missed = 0
    }
    
    var successRate: Double {
        guard attempts > 0 else { return 0 }
        return Double(goals) / Double(attempts) * 100
    }
}
