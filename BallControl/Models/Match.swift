import Foundation

struct PenaltyShootout: Codable, Identifiable {
    let id: UUID
    var playerName: String
    var opponentName: String
    var playerShots: [PenaltyShot]
    var opponentShots: [PenaltyShot]
    var date: Date
    var status: ShootoutStatus
    var difficulty: Difficulty
    
    init(id: UUID = UUID(), playerName: String = "You", opponentName: String = "CPU", playerShots: [PenaltyShot] = [], opponentShots: [PenaltyShot] = [], date: Date = Date(), status: ShootoutStatus = .inProgress, difficulty: Difficulty = .medium) {
        self.id = id
        self.playerName = playerName
        self.opponentName = opponentName
        self.playerShots = playerShots
        self.opponentShots = opponentShots
        self.date = date
        self.status = status
        self.difficulty = difficulty
    }
    
    var playerScore: Int {
        return playerShots.filter { $0.result == .goal }.count
    }
    
    var opponentScore: Int {
        return opponentShots.filter { $0.result == .goal }.count
    }
    
    var currentRound: Int {
        return max(playerShots.count, opponentShots.count) + 1
    }
    
    var isPlayerTurn: Bool {
        return playerShots.count <= opponentShots.count
    }
    
    var resultText: String {
        if status == .inProgress { return "In Progress" }
        if playerScore > opponentScore { return "Win" }
        if playerScore < opponentScore { return "Loss" }
        return "Draw"
    }
}

enum ShootoutStatus: String, Codable {
    case inProgress
    case completed
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var saveChance: Double {
        switch self {
        case .easy: return 0.2
        case .medium: return 0.35
        case .hard: return 0.5
        }
    }
    
    var cpuAccuracy: Double {
        switch self {
        case .easy: return 0.5
        case .medium: return 0.65
        case .hard: return 0.8
        }
    }
}

struct PenaltyShot: Codable, Identifiable {
    let id: UUID
    let round: Int
    let targetZone: ShotZone
    let keeperZone: ShotZone
    let result: ShotResult
    let isPlayerShot: Bool
    
    init(id: UUID = UUID(), round: Int, targetZone: ShotZone, keeperZone: ShotZone, result: ShotResult, isPlayerShot: Bool) {
        self.id = id
        self.round = round
        self.targetZone = targetZone
        self.keeperZone = keeperZone
        self.result = result
        self.isPlayerShot = isPlayerShot
    }
}

enum ShotZone: Int, Codable, CaseIterable {
    case topLeft = 0
    case topCenter = 1
    case topRight = 2
    case bottomLeft = 3
    case bottomCenter = 4
    case bottomRight = 5
    
    var displayName: String {
        switch self {
        case .topLeft: return "Top Left"
        case .topCenter: return "Top Center"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomCenter: return "Bottom Center"
        case .bottomRight: return "Bottom Right"
        }
    }
    
    static var random: ShotZone {
        return allCases.randomElement() ?? .bottomCenter
    }
}

enum ShotResult: String, Codable {
    case goal
    case saved
    case missed
}
