import SpriteKit

protocol PenaltySceneDelegate: AnyObject {
    func didShootBall(to zone: ShotZone)
    func didSelectKeeperZone(_ zone: ShotZone)
}

final class PenaltyScene: SKScene {
    
    weak var penaltyDelegate: PenaltySceneDelegate?
    
    private var ball: SKShapeNode!
    private var ballShadow: SKShapeNode!
    private var keeper: SKNode!
    private var keeperBody: SKShapeNode!
    private var keeperHead: SKShapeNode!
    private var keeperLeftArm: SKShapeNode!
    private var keeperRightArm: SKShapeNode!
    private var keeperLeftLeg: SKShapeNode!
    private var keeperRightLeg: SKShapeNode!
    private var zoneTouchAreas: [ShotZone: SKShapeNode] = [:]
    private var aimLine: SKShapeNode?
    
    private var goalX: CGFloat = 0
    private var goalY: CGFloat = 0
    private var goalWidth: CGFloat = 0
    private var goalHeight: CGFloat = 0
    private var grassHeight: CGFloat = 0
    private var ballStartPos: CGPoint = .zero
    
    private var isShootingMode = true
    private var isAnimating = false
    private var isDragging = false
    private var dragStartPoint: CGPoint = .zero
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#1B5E20") ?? .systemGreen
        setupScene()
    }
    
    private func setupScene() {
        grassHeight = size.height * 0.32
        goalWidth = size.width * 0.82
        goalHeight = size.height * 0.52
        goalX = (size.width - goalWidth) / 2
        goalY = grassHeight
        
        if goalY + goalHeight > size.height - 4 {
            goalHeight = size.height - goalY - 4
        }
        
        let skyGradient = SKShapeNode(rect: CGRect(x: 0, y: grassHeight, width: size.width, height: size.height - grassHeight))
        skyGradient.fillColor = UIColor(hex: "#1B5E20") ?? .systemGreen
        skyGradient.strokeColor = .clear
        skyGradient.zPosition = -1
        addChild(skyGradient)
        
        let grass = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: grassHeight))
        grass.fillColor = UIColor(hex: "#2E7D32") ?? .green
        grass.strokeColor = .clear
        grass.zPosition = 0
        addChild(grass)
        
        for i in 0..<6 {
            let stripeY = CGFloat(i) * (grassHeight / 6)
            let stripe = SKShapeNode(rect: CGRect(x: 0, y: stripeY, width: size.width, height: grassHeight / 12))
            stripe.fillColor = UIColor(hex: "#388E3C")?.withAlphaComponent(0.3) ?? .clear
            stripe.strokeColor = .clear
            stripe.zPosition = 0
            addChild(stripe)
        }
        
        let postW: CGFloat = 6
        
        let netBg = SKShapeNode(rect: CGRect(x: goalX + postW, y: goalY, width: goalWidth - postW * 2, height: goalHeight - postW))
        netBg.fillColor = UIColor(hex: "#145218")?.withAlphaComponent(0.6) ?? .black.withAlphaComponent(0.3)
        netBg.strokeColor = .clear
        netBg.zPosition = 1
        addChild(netBg)
        
        let spacing: CGFloat = 18
        let innerW = goalWidth - postW * 2
        let innerH = goalHeight - postW
        
        var x = goalX + postW + spacing
        while x < goalX + goalWidth - postW {
            let p = CGMutablePath()
            p.move(to: CGPoint(x: x, y: goalY))
            p.addLine(to: CGPoint(x: x, y: goalY + innerH))
            let l = SKShapeNode(path: p)
            l.strokeColor = .white.withAlphaComponent(0.12)
            l.lineWidth = 1
            l.zPosition = 2
            addChild(l)
            x += spacing
        }
        var y = goalY + spacing
        while y < goalY + innerH {
            let p = CGMutablePath()
            p.move(to: CGPoint(x: goalX + postW, y: y))
            p.addLine(to: CGPoint(x: goalX + goalWidth - postW, y: y))
            let l = SKShapeNode(path: p)
            l.strokeColor = .white.withAlphaComponent(0.12)
            l.lineWidth = 1
            l.zPosition = 2
            addChild(l)
            y += spacing
        }
        
        let leftPost = SKShapeNode(rectOf: CGSize(width: postW, height: goalHeight + 4), cornerRadius: 2)
        leftPost.position = CGPoint(x: goalX + postW / 2, y: goalY + goalHeight / 2)
        leftPost.fillColor = .white
        leftPost.strokeColor = UIColor.lightGray
        leftPost.lineWidth = 1
        leftPost.zPosition = 6
        addChild(leftPost)
        
        let rightPost = SKShapeNode(rectOf: CGSize(width: postW, height: goalHeight + 4), cornerRadius: 2)
        rightPost.position = CGPoint(x: goalX + goalWidth - postW / 2, y: goalY + goalHeight / 2)
        rightPost.fillColor = .white
        rightPost.strokeColor = UIColor.lightGray
        rightPost.lineWidth = 1
        rightPost.zPosition = 6
        addChild(rightPost)
        
        let crossbar = SKShapeNode(rectOf: CGSize(width: goalWidth + 4, height: postW), cornerRadius: 2)
        crossbar.position = CGPoint(x: size.width / 2, y: goalY + goalHeight)
        crossbar.fillColor = .white
        crossbar.strokeColor = UIColor.lightGray
        crossbar.lineWidth = 1
        crossbar.zPosition = 7
        addChild(crossbar)
        
        setupZones()
        setupKeeper()
        setupBall()
    }
    
    private func setupZones() {
        let postW: CGFloat = 7
        let innerW = goalWidth - postW * 2
        let innerH = goalHeight - postW
        let zw = innerW / 3
        let zh = innerH / 2
        
        let zones: [[ShotZone]] = [
            [.bottomLeft, .bottomCenter, .bottomRight],
            [.topLeft, .topCenter, .topRight]
        ]
        
        for row in 0..<2 {
            for col in 0..<3 {
                let zone = zones[row][col]
                let rx = goalX + postW + CGFloat(col) * zw
                let ry = goalY + CGFloat(row) * zh
                let rect = CGRect(x: rx, y: ry, width: zw, height: zh)
                let node = SKShapeNode(rect: rect, cornerRadius: 2)
                node.fillColor = .clear
                node.strokeColor = .clear
                node.zPosition = 8
                node.name = "zone_\(zone.rawValue)"
                addChild(node)
                zoneTouchAreas[zone] = node
            }
        }
    }
    
    private func setupKeeper() {
        let keeperScale = min(1.0, goalHeight / 180)
        
        keeper = SKNode()
        keeper.zPosition = 4
        keeper.setScale(keeperScale)
        keeper.position = CGPoint(x: size.width / 2, y: goalY + goalHeight * 0.32)
        addChild(keeper)
        
        keeperBody = SKShapeNode(rectOf: CGSize(width: 22, height: 36), cornerRadius: 4)
        keeperBody.fillColor = UIColor(hex: "#E65100") ?? .orange
        keeperBody.strokeColor = UIColor(hex: "#BF360C") ?? .red
        keeperBody.lineWidth = 1.5
        keeperBody.position = .zero
        keeper.addChild(keeperBody)
        
        keeperHead = SKShapeNode(circleOfRadius: 10)
        keeperHead.fillColor = UIColor(hex: "#FFCC80") ?? .systemOrange
        keeperHead.strokeColor = UIColor(hex: "#E65100") ?? .orange
        keeperHead.lineWidth = 1.5
        keeperHead.position = CGPoint(x: 0, y: 28)
        keeper.addChild(keeperHead)
        
        keeperLeftArm = SKShapeNode(rectOf: CGSize(width: 8, height: 24), cornerRadius: 3)
        keeperLeftArm.fillColor = UIColor(hex: "#E65100") ?? .orange
        keeperLeftArm.strokeColor = UIColor(hex: "#BF360C") ?? .red
        keeperLeftArm.lineWidth = 1
        keeperLeftArm.position = CGPoint(x: -17, y: 6)
        keeper.addChild(keeperLeftArm)
        
        keeperRightArm = SKShapeNode(rectOf: CGSize(width: 8, height: 24), cornerRadius: 3)
        keeperRightArm.fillColor = UIColor(hex: "#E65100") ?? .orange
        keeperRightArm.strokeColor = UIColor(hex: "#BF360C") ?? .red
        keeperRightArm.lineWidth = 1
        keeperRightArm.position = CGPoint(x: 17, y: 6)
        keeper.addChild(keeperRightArm)
        
        let gloveL = SKShapeNode(circleOfRadius: 6)
        gloveL.fillColor = UIColor(hex: "#FFC107") ?? .yellow
        gloveL.strokeColor = UIColor(hex: "#FF8F00") ?? .orange
        gloveL.lineWidth = 1
        gloveL.position = CGPoint(x: 0, y: 12)
        keeperLeftArm.addChild(gloveL)
        
        let gloveR = SKShapeNode(circleOfRadius: 6)
        gloveR.fillColor = UIColor(hex: "#FFC107") ?? .yellow
        gloveR.strokeColor = UIColor(hex: "#FF8F00") ?? .orange
        gloveR.lineWidth = 1
        gloveR.position = CGPoint(x: 0, y: 12)
        keeperRightArm.addChild(gloveR)
        
        keeperLeftLeg = SKShapeNode(rectOf: CGSize(width: 9, height: 20), cornerRadius: 3)
        keeperLeftLeg.fillColor = UIColor(hex: "#212121") ?? .darkGray
        keeperLeftLeg.strokeColor = .clear
        keeperLeftLeg.position = CGPoint(x: -7, y: -26)
        keeper.addChild(keeperLeftLeg)
        
        keeperRightLeg = SKShapeNode(rectOf: CGSize(width: 9, height: 20), cornerRadius: 3)
        keeperRightLeg.fillColor = UIColor(hex: "#212121") ?? .darkGray
        keeperRightLeg.strokeColor = .clear
        keeperRightLeg.position = CGPoint(x: 7, y: -26)
        keeper.addChild(keeperRightLeg)
    }
    
    private func setupBall() {
        let ballR: CGFloat = 14
        ballStartPos = CGPoint(x: size.width / 2, y: grassHeight * 0.45)
        
        ballShadow = SKShapeNode(ellipseOf: CGSize(width: 26, height: 9))
        ballShadow.fillColor = .black.withAlphaComponent(0.2)
        ballShadow.strokeColor = .clear
        ballShadow.position = CGPoint(x: ballStartPos.x, y: ballStartPos.y - 11)
        ballShadow.zPosition = 9
        addChild(ballShadow)
        
        ball = SKShapeNode(circleOfRadius: ballR)
        ball.position = ballStartPos
        ball.fillColor = .white
        ball.strokeColor = .clear
        ball.lineWidth = 0
        ball.zPosition = 10
        addChild(ball)
        
        let ring = SKShapeNode(circleOfRadius: ballR)
        ring.fillColor = .clear
        ring.strokeColor = UIColor.gray.withAlphaComponent(0.5)
        ring.lineWidth = 2
        ball.addChild(ring)
        
        let pentagon = SKShapeNode(circleOfRadius: 5.5)
        pentagon.fillColor = UIColor.darkGray.withAlphaComponent(0.6)
        pentagon.strokeColor = .clear
        ball.addChild(pentagon)
        
        for i in 0..<5 {
            let angle = CGFloat(i) * .pi * 2 / 5 - .pi / 2
            let dot = SKShapeNode(circleOfRadius: 2.5)
            dot.position = CGPoint(x: cos(angle) * 10, y: sin(angle) * 10)
            dot.fillColor = UIColor.darkGray.withAlphaComponent(0.4)
            dot.strokeColor = .clear
            ball.addChild(dot)
        }
    }
    
    func showShootingZones() {
        isShootingMode = true
        isAnimating = false
        resetPositions()
        
        for (_, node) in zoneTouchAreas {
            node.fillColor = .clear
            node.strokeColor = .clear
        }
        
        let hint = SKLabelNode(text: "Swipe the ball toward the goal!")
        hint.fontName = "AvenirNext-Medium"
        hint.fontSize = 13
        hint.fontColor = .white.withAlphaComponent(0.7)
        hint.position = CGPoint(x: size.width / 2, y: max(4, ballStartPos.y - 28))
        hint.zPosition = 20
        hint.name = "hint"
        addChild(hint)
        hint.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()]))
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.12, duration: 0.6),
            SKAction.scale(to: 1.0, duration: 0.6)
        ])
        ball.run(SKAction.repeatForever(pulse), withKey: "pulse")
    }
    
    func showKeepingZones() {
        isShootingMode = false
        isAnimating = false
        resetPositions()
        
        for (_, node) in zoneTouchAreas {
            node.fillColor = UIColor(hex: "#FFC107")?.withAlphaComponent(0.1) ?? .clear
            node.strokeColor = UIColor(hex: "#FFC107")?.withAlphaComponent(0.4) ?? .clear
            node.lineWidth = 1.5
        }
        
        ball.removeAction(forKey: "pulse")
        ball.setScale(1.0)
    }
    
    func hideZones() {
        for (_, node) in zoneTouchAreas {
            node.fillColor = .clear
            node.strokeColor = .clear
        }
        ball.removeAction(forKey: "pulse")
        ball.setScale(1.0)
    }
    
    private func resetPositions() {
        ball.removeAllActions()
        ball.position = ballStartPos
        ball.setScale(1.0)
        ball.alpha = 1.0
        ballShadow.position = CGPoint(x: ballStartPos.x, y: ballStartPos.y - 11)
        ballShadow.alpha = 1.0
        ballShadow.setScale(1.0)
        
        keeper.position = CGPoint(x: size.width / 2, y: goalY + goalHeight * 0.32)
        keeper.zRotation = 0
        keeperLeftArm.zRotation = 0
        keeperRightArm.zRotation = 0
        keeperLeftArm.position = CGPoint(x: -17, y: 6)
        keeperRightArm.position = CGPoint(x: 17, y: 6)
        keeperLeftLeg.position = CGPoint(x: -7, y: -26)
        keeperRightLeg.position = CGPoint(x: 7, y: -26)
        keeperBody.zRotation = 0
        keeperHead.position = CGPoint(x: 0, y: 28)
        
        aimLine?.removeFromParent()
        aimLine = nil
        
        enumerateChildNodes(withName: "hint") { node, _ in node.removeFromParent() }
    }
    
    func animateShot(target: ShotZone, keeperDive: ShotZone, result: ShotResult, completion: @escaping () -> Void) {
        guard !isAnimating else { return }
        isAnimating = true
        hideZones()
        ball.removeAction(forKey: "pulse")
        ball.setScale(1.0)
        
        let keeperTarget = zoneCenter(keeperDive)
        let duration: Double = 0.38
        
        animateKeeperDive(to: keeperDive, targetPos: keeperTarget, duration: duration)
        
        if result == .missed {
            let missPos = missPosition(near: target)
            let missAction = SKAction.group([
                SKAction.move(to: missPos, duration: duration),
                SKAction.scale(to: 0.4, duration: duration)
            ])
            missAction.timingMode = .easeIn
            ballShadow.run(SKAction.fadeAlpha(to: 0, duration: duration * 0.5))
            ball.run(missAction) { [weak self] in
                guard let self = self else { return }
                self.ball.run(SKAction.fadeOut(withDuration: 0.15))
                self.showResultLabel("MISSED!", color: .systemOrange)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.isAnimating = false
                    completion()
                }
            }
        } else {
            let targetPos = zoneCenter(target)
            let shootAction = SKAction.group([
                SKAction.move(to: targetPos, duration: duration),
                SKAction.scale(to: 0.5, duration: duration)
            ])
            shootAction.timingMode = .easeIn
            let shadowAction = SKAction.group([
                SKAction.move(to: CGPoint(x: targetPos.x, y: targetPos.y - 8), duration: duration),
                SKAction.scale(to: 0.4, duration: duration),
                SKAction.fadeAlpha(to: 0.1, duration: duration)
            ])
            ballShadow.run(shadowAction)
            ball.run(shootAction) { [weak self] in
                guard let self = self else { return }
                self.handleShotResult(result, at: targetPos, isPlayerShot: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.isAnimating = false
                    completion()
                }
            }
        }
    }
    
    func animateOpponentShot(target: ShotZone, keeperDive: ShotZone, result: ShotResult, completion: @escaping () -> Void) {
        guard !isAnimating else { return }
        isAnimating = true
        hideZones()
        
        ball.position = ballStartPos
        ball.setScale(1.0)
        ball.alpha = 1.0
        ballShadow.position = CGPoint(x: ballStartPos.x, y: ballStartPos.y - 11)
        ballShadow.alpha = 1.0
        ballShadow.setScale(1.0)
        
        let duration: Double = 0.4
        let keeperTarget = zoneCenter(keeperDive)
        animateKeeperDive(to: keeperDive, targetPos: keeperTarget, duration: duration)
        
        if result == .missed {
            let missPos = missPosition(near: target)
            let missAction = SKAction.group([
                SKAction.move(to: missPos, duration: duration),
                SKAction.scale(to: 0.45, duration: duration)
            ])
            missAction.timingMode = .easeIn
            ballShadow.run(SKAction.fadeAlpha(to: 0, duration: duration * 0.5))
            ball.run(missAction) { [weak self] in
                guard let self = self else { return }
                self.ball.run(SKAction.fadeOut(withDuration: 0.15))
                self.showResultLabel("MISSED!", color: UIColor(hex: "#2E7D32") ?? .systemGreen)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.isAnimating = false
                    completion()
                }
            }
        } else {
            let targetPos = zoneCenter(target)
            let shootAction = SKAction.group([
                SKAction.move(to: targetPos, duration: duration),
                SKAction.scale(to: 0.5, duration: duration)
            ])
            shootAction.timingMode = .easeIn
            let shadowAction = SKAction.group([
                SKAction.move(to: CGPoint(x: targetPos.x, y: targetPos.y - 8), duration: duration),
                SKAction.scale(to: 0.4, duration: duration),
                SKAction.fadeAlpha(to: 0.1, duration: duration)
            ])
            ballShadow.run(shadowAction)
            ball.run(shootAction) { [weak self] in
                guard let self = self else { return }
                self.handleShotResult(result, at: targetPos, isPlayerShot: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.isAnimating = false
                    completion()
                }
            }
        }
    }
    
    private func missPosition(near zone: ShotZone) -> CGPoint {
        let postW: CGFloat = 7
        let center = zoneCenter(zone)
        switch zone {
        case .topLeft:
            return CGPoint(x: goalX - 20, y: goalY + goalHeight + 25)
        case .topCenter:
            return CGPoint(x: center.x + CGFloat.random(in: -30...30), y: goalY + goalHeight + 30)
        case .topRight:
            return CGPoint(x: goalX + goalWidth + 20, y: goalY + goalHeight + 25)
        case .bottomLeft:
            return CGPoint(x: goalX - 25, y: center.y)
        case .bottomCenter:
            let side: CGFloat = Bool.random() ? -1 : 1
            return CGPoint(x: center.x + side * (goalWidth * 0.5 + 15), y: center.y)
        case .bottomRight:
            return CGPoint(x: goalX + goalWidth + 25, y: center.y)
        }
    }
    
    private func animateKeeperDive(to zone: ShotZone, targetPos: CGPoint, duration: TimeInterval) {
        let diveX = targetPos.x
        let diveY = targetPos.y
        let isLeft = diveX < size.width / 2 - 20
        let isRight = diveX > size.width / 2 + 20
        let isTop = diveY > goalY + goalHeight * 0.5
        
        let keeperStartY = goalY + goalHeight * 0.32
        let targetKeeperY: CGFloat
        if isTop {
            targetKeeperY = min(diveY - 15, goalY + goalHeight * 0.65)
        } else {
            targetKeeperY = max(diveY + 5, goalY + goalHeight * 0.15)
        }
        
        let moveAction = SKAction.move(to: CGPoint(x: diveX, y: targetKeeperY), duration: duration + 0.05)
        moveAction.timingMode = .easeOut
        
        var rotAngle: CGFloat = 0
        if isLeft { rotAngle = isTop ? 0.6 : 0.4 }
        else if isRight { rotAngle = isTop ? -0.6 : -0.4 }
        
        keeper.run(moveAction)
        keeper.run(SKAction.rotate(toAngle: rotAngle, duration: duration))
        
        let armDur = duration * 0.7
        if isLeft {
            keeperLeftArm.run(SKAction.group([
                SKAction.rotate(toAngle: isTop ? 1.5 : 0.9, duration: armDur),
                SKAction.moveBy(x: -14, y: isTop ? 16 : 6, duration: armDur)
            ]))
            keeperRightArm.run(SKAction.rotate(toAngle: isTop ? 0.6 : 0.3, duration: armDur))
            keeperLeftLeg.run(SKAction.moveBy(x: -8, y: isTop ? 6 : -4, duration: armDur))
            keeperRightLeg.run(SKAction.moveBy(x: 4, y: isTop ? 4 : -2, duration: armDur))
        } else if isRight {
            keeperRightArm.run(SKAction.group([
                SKAction.rotate(toAngle: isTop ? -1.5 : -0.9, duration: armDur),
                SKAction.moveBy(x: 14, y: isTop ? 16 : 6, duration: armDur)
            ]))
            keeperLeftArm.run(SKAction.rotate(toAngle: isTop ? -0.6 : -0.3, duration: armDur))
            keeperRightLeg.run(SKAction.moveBy(x: 8, y: isTop ? 6 : -4, duration: armDur))
            keeperLeftLeg.run(SKAction.moveBy(x: -4, y: isTop ? 4 : -2, duration: armDur))
        } else {
            if isTop {
                keeperLeftArm.run(SKAction.group([
                    SKAction.rotate(toAngle: 1.0, duration: armDur),
                    SKAction.moveBy(x: -8, y: 14, duration: armDur)
                ]))
                keeperRightArm.run(SKAction.group([
                    SKAction.rotate(toAngle: -1.0, duration: armDur),
                    SKAction.moveBy(x: 8, y: 14, duration: armDur)
                ]))
            } else {
                keeperLeftArm.run(SKAction.group([
                    SKAction.rotate(toAngle: 0.5, duration: armDur),
                    SKAction.moveBy(x: -6, y: -4, duration: armDur)
                ]))
                keeperRightArm.run(SKAction.group([
                    SKAction.rotate(toAngle: -0.5, duration: armDur),
                    SKAction.moveBy(x: 6, y: -4, duration: armDur)
                ]))
                keeperLeftLeg.run(SKAction.moveBy(x: -4, y: -6, duration: armDur))
                keeperRightLeg.run(SKAction.moveBy(x: 4, y: -6, duration: armDur))
            }
        }
    }
    
    private func handleShotResult(_ result: ShotResult, at pos: CGPoint, isPlayerShot: Bool) {
        switch result {
        case .saved:
            let bounceDir: CGFloat = pos.x < size.width / 2 ? -1 : 1
            ball.run(SKAction.sequence([
                SKAction.move(by: CGVector(dx: bounceDir * 30, dy: -40), duration: 0.2),
                SKAction.fadeOut(withDuration: 0.2)
            ]))
            let color: UIColor = isPlayerShot ? .systemRed : (UIColor(hex: "#2E7D32") ?? .systemGreen)
            showResultLabel("SAVED!", color: color)
        case .missed:
            break
        case .goal:
            showGoalNetEffect(at: pos)
            ball.run(SKAction.sequence([
                SKAction.move(by: CGVector(dx: 0, dy: 8), duration: 0.15),
                SKAction.move(by: CGVector(dx: 0, dy: -3), duration: 0.1)
            ]))
            let color: UIColor = isPlayerShot ? (UIColor(hex: "#2E7D32") ?? .systemGreen) : .systemRed
            showResultLabel("GOAL!", color: color)
        }
    }
    
    private func zoneCenter(_ zone: ShotZone) -> CGPoint {
        guard let node = zoneTouchAreas[zone] else { return CGPoint(x: size.width / 2, y: goalY + goalHeight / 2) }
        return CGPoint(x: node.frame.midX, y: node.frame.midY)
    }
    
    private func projectSwipeToZone(from origin: CGPoint, dx: CGFloat, dy: CGFloat, releaseY: CGFloat) -> ShotZone {
        let postW: CGFloat = 7
        let innerW = goalWidth - postW * 2
        let innerH = goalHeight - postW
        let goalMidY = goalY + innerH / 2
        let goalCenterX = goalX + postW + innerW / 2
        
        var hitX = goalCenterX
        if dy > 0 {
            let t = (goalMidY - origin.y) / dy
            hitX = origin.x + dx * t
        }
        
        let leftEdge = goalX + postW
        let rightEdge = goalX + postW + innerW
        hitX = min(max(hitX, leftEdge), rightEdge)
        
        let relX = (hitX - leftEdge) / innerW
        
        let col: Int
        if relX < 0.333 { col = 0 }
        else if relX < 0.666 { col = 1 }
        else { col = 2 }
        
        let topThreshold = goalY + innerH * 0.35
        let isTop = releaseY > topThreshold
        let row = isTop ? 1 : 0
        
        let zones: [[ShotZone]] = [
            [.bottomLeft, .bottomCenter, .bottomRight],
            [.topLeft, .topCenter, .topRight]
        ]
        return zones[row][col]
    }
    
    private func showResultLabel(_ text: String, color: UIColor) {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 34
        label.fontColor = color
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.80)
        label.zPosition = 25
        label.alpha = 0
        label.setScale(0.4)
        addChild(label)
        
        let shadow = SKLabelNode(text: text)
        shadow.fontName = "AvenirNext-Heavy"
        shadow.fontSize = 34
        shadow.fontColor = .black.withAlphaComponent(0.3)
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        label.addChild(shadow)
        
        label.run(SKAction.sequence([
            SKAction.group([SKAction.fadeIn(withDuration: 0.12), SKAction.scale(to: 1.15, duration: 0.12)]),
            SKAction.scale(to: 1.0, duration: 0.08),
            SKAction.wait(forDuration: 0.7),
            SKAction.group([SKAction.fadeOut(withDuration: 0.25), SKAction.scale(to: 0.7, duration: 0.25)]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func showGoalNetEffect(at position: CGPoint) {
        for i in 0..<10 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            dot.position = position
            dot.fillColor = .white
            dot.strokeColor = .clear
            dot.zPosition = 15
            dot.alpha = 0.8
            addChild(dot)
            
            let angle = CGFloat(i) * .pi * 2 / 10 + CGFloat.random(in: -0.2...0.2)
            let dist = CGFloat.random(in: 25...50)
            let target = CGPoint(x: position.x + cos(angle) * dist, y: position.y + sin(angle) * dist)
            dot.run(SKAction.sequence([
                SKAction.group([SKAction.move(to: target, duration: 0.3), SKAction.fadeOut(withDuration: 0.35)]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimating, let touch = touches.first else { return }
        let loc = touch.location(in: self)
        
        if !isShootingMode {
            for (zone, node) in zoneTouchAreas {
                if node.frame.contains(loc) {
                    node.fillColor = UIColor(hex: "#FFC107")?.withAlphaComponent(0.35) ?? .yellow.withAlphaComponent(0.35)
                    penaltyDelegate?.didSelectKeeperZone(zone)
                    return
                }
            }
            return
        }
        
        let dist = hypot(loc.x - ball.position.x, loc.y - ball.position.y)
        if dist < 40 {
            isDragging = true
            dragStartPoint = loc
            ball.removeAction(forKey: "pulse")
            ball.setScale(1.08)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, isShootingMode, let touch = touches.first else { return }
        let loc = touch.location(in: self)
        
        let dy = loc.y - dragStartPoint.y
        if dy > 15 {
            aimLine?.removeFromParent()
            let path = CGMutablePath()
            path.move(to: ball.position)
            path.addLine(to: loc)
            aimLine = SKShapeNode(path: path)
            aimLine?.strokeColor = .white.withAlphaComponent(0.5)
            aimLine?.lineWidth = 2
            aimLine?.zPosition = 9
            if let line = aimLine { addChild(line) }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, isShootingMode, let touch = touches.first else { return }
        isDragging = false
        ball.setScale(1.0)
        aimLine?.removeFromParent()
        aimLine = nil
        
        let loc = touch.location(in: self)
        let dx = loc.x - dragStartPoint.x
        let dy = loc.y - dragStartPoint.y
        let dist = hypot(dx, dy)
        
        guard dy > 30 && dist > 40 else { return }
        
        let zone = projectSwipeToZone(from: ballStartPos, dx: dx, dy: dy, releaseY: loc.y)
        penaltyDelegate?.didShootBall(to: zone)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
        ball.setScale(1.0)
        aimLine?.removeFromParent()
        aimLine = nil
    }
    
}
