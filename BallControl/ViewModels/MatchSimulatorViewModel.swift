import Foundation

protocol PenaltyViewModelDelegate: AnyObject {
    func stateDidChange(_ state: PenaltyViewModel.GameState)
    func shootoutDidEnd(_ shootout: PenaltyShootout)
}

final class PenaltyViewModel {
    
    enum GameState {
        case ready
        case playerShooting
        case playerKeeping
        case animating
        case roundResult(String)
        case finished
    }
    
    weak var delegate: PenaltyViewModelDelegate?
    
    private let dataManager = DataManager.shared
    private(set) var shootout: PenaltyShootout
    private(set) var state: GameState = .ready
    
    var difficulty: Difficulty = .medium {
        didSet { shootout.difficulty = difficulty }
    }
    
    var totalRounds: Int = 5
    
    var playerScore: Int { shootout.playerScore }
    var opponentScore: Int { shootout.opponentScore }
    var currentRound: Int { shootout.currentRound }
    
    var statusText: String {
        switch state {
        case .ready: return "Tap Play to Start"
        case .playerShooting: return "Swipe the ball to shoot!"
        case .playerKeeping: return "Tap a zone to dive!"
        case .animating: return ""
        case .roundResult(let text): return text
        case .finished: return shootout.resultText
        }
    }
    
    init() {
        self.shootout = PenaltyShootout(difficulty: .medium)
    }
    
    func startNew() {
        shootout = PenaltyShootout(difficulty: difficulty)
        state = .playerShooting
        delegate?.stateDidChange(state)
    }
    
    func playerShoot(target: ShotZone) -> (keeperZone: ShotZone, result: ShotResult) {
        state = .animating
        delegate?.stateDidChange(state)
        
        let keeperZone = generateKeeperDive(for: target)
        let result = resolveShot(target: target, keeper: keeperZone)
        
        let shot = PenaltyShot(round: currentRound, targetZone: target, keeperZone: keeperZone, result: result, isPlayerShot: true)
        shootout.playerShots.append(shot)
        
        return (keeperZone, result)
    }
    
    func afterPlayerShot() {
        if checkShootoutEnd() {
            finishShootout()
            return
        }
        state = .playerKeeping
        delegate?.stateDidChange(state)
    }
    
    func playerDive(keeperZone: ShotZone) -> (target: ShotZone, result: ShotResult) {
        state = .animating
        delegate?.stateDidChange(state)
        
        let target = generateCPUShotTarget()
        let missChance = 1.0 - shootout.difficulty.cpuAccuracy
        let result = resolveOpponentShot(target: target, keeper: keeperZone, missChance: missChance)
        
        let shot = PenaltyShot(round: currentRound - 1, targetZone: target, keeperZone: keeperZone, result: result, isPlayerShot: false)
        shootout.opponentShots.append(shot)
        
        return (target, result)
    }
    
    func afterOpponentShot() {
        if checkShootoutEnd() {
            finishShootout()
            return
        }
        state = .playerShooting
        delegate?.stateDidChange(state)
    }
    
    private func generateKeeperDive(for target: ShotZone) -> ShotZone {
        let saveChance = shootout.difficulty.saveChance
        
        if Double.random(in: 0...1) < saveChance {
            return target
        }
        
        let adjacent = adjacentZones(for: target)
        if Double.random(in: 0...1) < 0.4, let adj = adjacent.randomElement() {
            return adj
        }
        
        let others = ShotZone.allCases.filter { $0 != target }
        return others.randomElement() ?? .bottomCenter
    }
    
    private func adjacentZones(for zone: ShotZone) -> [ShotZone] {
        switch zone {
        case .topLeft: return [.topCenter, .bottomLeft]
        case .topCenter: return [.topLeft, .topRight, .bottomCenter]
        case .topRight: return [.topCenter, .bottomRight]
        case .bottomLeft: return [.bottomCenter, .topLeft]
        case .bottomCenter: return [.bottomLeft, .bottomRight, .topCenter]
        case .bottomRight: return [.bottomCenter, .topRight]
        }
    }
    
    private func resolveShot(target: ShotZone, keeper: ShotZone) -> ShotResult {
        if Double.random(in: 0...1) < 0.06 {
            return .missed
        }
        if target == keeper {
            return .saved
        }
        return .goal
    }
    
    private func generateCPUShotTarget() -> ShotZone {
        let corners: [ShotZone] = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        let center: [ShotZone] = [.topCenter, .bottomCenter]
        
        switch difficulty {
        case .easy:
            return ShotZone.random
        case .medium:
            if Double.random(in: 0...1) < 0.6 { return corners.randomElement() ?? .bottomLeft }
            return center.randomElement() ?? .bottomCenter
        case .hard:
            if Double.random(in: 0...1) < 0.75 { return corners.randomElement() ?? .topRight }
            return center.randomElement() ?? .topCenter
        }
    }
    
    private func resolveOpponentShot(target: ShotZone, keeper: ShotZone, missChance: Double) -> ShotResult {
        if Double.random(in: 0...1) < missChance {
            return .missed
        }
        if target == keeper {
            return .saved
        }
        return .goal
    }
    
    private func checkShootoutEnd() -> Bool {
        let pShots = shootout.playerShots.count
        let oShots = shootout.opponentShots.count
        
        if pShots >= totalRounds && oShots >= totalRounds {
            if shootout.playerScore != shootout.opponentScore {
                return true
            }
            if pShots >= totalRounds + 3 && oShots >= totalRounds + 3 {
                if shootout.playerScore != shootout.opponentScore {
                    return true
                }
            }
        }
        
        let pRemaining = max(0, totalRounds - pShots)
        let oRemaining = max(0, totalRounds - oShots)
        
        if pShots >= totalRounds && oShots >= totalRounds && pShots == oShots {
            return shootout.playerScore != shootout.opponentScore
        }
        
        if shootout.playerScore > shootout.opponentScore + oRemaining {
            return true
        }
        if shootout.opponentScore > shootout.playerScore + pRemaining {
            return true
        }
        
        return false
    }
    
    private func finishShootout() {
        shootout.status = .completed
        dataManager.addShootout(shootout)
        dataManager.updatePlayerStats(with: shootout)
        state = .finished
        delegate?.stateDidChange(state)
        delegate?.shootoutDidEnd(shootout)
    }
}
