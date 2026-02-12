import UIKit
import SpriteKit

final class PenaltyViewController: UIViewController {
    
    private var viewModel = PenaltyViewModel()
    private var gameScene: PenaltyScene!
    private var skView: SKView!
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .black)
        label.textAlignment = .center
        label.text = "0 - 0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.text = "YOU"
        label.textColor = UIColor(hex: "#2E7D32")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cpuLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.text = "CPU"
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.text = "Tap Play to Start"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = UIColor(hex: "#1B5E20")
        label.layer.cornerRadius = 7
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PLAY", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#2E7D32")
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let difficultyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Medium", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.tintColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var bottomControlsView: UIView!
    private var skViewBottomToControls: NSLayoutConstraint!
    private var skViewBottomToSafeArea: NSLayoutConstraint!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupUI()
        setupGameView()
    }
    
    private func setupUI() {
        title = "Penalty Shootout"
        view.backgroundColor = .systemBackground
        
        bottomControlsView = UIView()
        bottomControlsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomControlsView)
        
        bottomControlsView.addSubview(statusLabel)
        bottomControlsView.addSubview(playButton)
        bottomControlsView.addSubview(difficultyButton)
        
        view.addSubview(roundLabel)
        view.addSubview(playerLabel)
        view.addSubview(scoreLabel)
        view.addSubview(cpuLabel)
        
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        difficultyButton.addTarget(self, action: #selector(changeDifficulty), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            roundLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            roundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roundLabel.widthAnchor.constraint(equalToConstant: 80),
            roundLabel.heightAnchor.constraint(equalToConstant: 24),
            
            scoreLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: 2),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            playerLabel.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor, constant: -12),
            playerLabel.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor),
            
            cpuLabel.leadingAnchor.constraint(equalTo: scoreLabel.trailingAnchor, constant: 12),
            cpuLabel.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor),
            
            bottomControlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomControlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomControlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: bottomControlsView.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: bottomControlsView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: bottomControlsView.trailingAnchor, constant: -16),
            
            playButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            playButton.centerXAnchor.constraint(equalTo: bottomControlsView.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 160),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.bottomAnchor.constraint(equalTo: bottomControlsView.bottomAnchor, constant: -8),
            
            difficultyButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            difficultyButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -16)
        ])
        
        roundLabel.text = "Round 1"
    }
    
    private func setupGameView() {
        skView = SKView()
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.ignoresSiblingOrder = true
        view.addSubview(skView)
        view.bringSubviewToFront(bottomControlsView)
        
        skViewBottomToControls = skView.bottomAnchor.constraint(equalTo: bottomControlsView.topAnchor)
        skViewBottomToSafeArea = skView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 4),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skViewBottomToControls
        ])
        
        view.layoutIfNeeded()
        
        gameScene = PenaltyScene(size: skView.bounds.size)
        gameScene.scaleMode = .aspectFill
        gameScene.penaltyDelegate = self
        skView.presentScene(gameScene)
    }
    
    private func setGameLayout(playing: Bool) {
        if playing {
            bottomControlsView.isHidden = true
            skViewBottomToControls.isActive = false
            skViewBottomToSafeArea.isActive = true
        } else {
            skViewBottomToSafeArea.isActive = false
            skViewBottomToControls.isActive = true
            bottomControlsView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        let newSize = skView.bounds.size
        if newSize.width > 0 && newSize.height > 0 {
            gameScene = PenaltyScene(size: newSize)
            gameScene.scaleMode = .aspectFill
            gameScene.penaltyDelegate = self
            skView.presentScene(gameScene)
        }
    }
    
    @objc private func playTapped() {
        viewModel.startNew()
        updateUI()
    }
    
    @objc private func changeDifficulty() {
        let alert = UIAlertController(title: "Difficulty", message: nil, preferredStyle: .actionSheet)
        for diff in Difficulty.allCases {
            alert.addAction(UIAlertAction(title: diff.rawValue, style: .default) { [weak self] _ in
                self?.viewModel.difficulty = diff
                self?.difficultyButton.setTitle(diff.rawValue, for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func updateUI() {
        scoreLabel.text = "\(viewModel.playerScore) - \(viewModel.opponentScore)"
        statusLabel.text = viewModel.statusText
        roundLabel.text = "Round \(viewModel.currentRound)"
    }
}

extension PenaltyViewController: PenaltySceneDelegate {
    
    func didShootBall(to zone: ShotZone) {
        guard case .playerShooting = viewModel.state else { return }
        
        let result = viewModel.playerShoot(target: zone)
        updateUI()
        
        gameScene.animateShot(target: zone, keeperDive: result.keeperZone, result: result.result) { [weak self] in
            self?.viewModel.afterPlayerShot()
            self?.updateUI()
            
            if case .playerKeeping = self?.viewModel.state {
                self?.gameScene.showKeepingZones()
            }
        }
    }
    
    func didSelectKeeperZone(_ zone: ShotZone) {
        guard case .playerKeeping = viewModel.state else { return }
        
        let result = viewModel.playerDive(keeperZone: zone)
        updateUI()
        
        gameScene.animateOpponentShot(target: result.target, keeperDive: zone, result: result.result) { [weak self] in
            self?.viewModel.afterOpponentShot()
            self?.updateUI()
            
            if case .playerShooting = self?.viewModel.state {
                self?.gameScene.showShootingZones()
            }
        }
    }
}

extension PenaltyViewController: PenaltyViewModelDelegate {
    
    func stateDidChange(_ state: PenaltyViewModel.GameState) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI()
            
            switch state {
            case .playerShooting:
                self?.setGameLayout(playing: true)
                self?.gameScene.showShootingZones()
            case .playerKeeping:
                self?.gameScene.showKeepingZones()
            case .finished:
                self?.gameScene.hideZones()
                self?.playButton.setTitle("PLAY AGAIN", for: .normal)
                self?.setGameLayout(playing: false)
            case .ready:
                self?.playButton.setTitle("PLAY", for: .normal)
                self?.setGameLayout(playing: false)
            default:
                break
            }
        }
    }
    
    func shootoutDidEnd(_ shootout: PenaltyShootout) {
        DispatchQueue.main.async { [weak self] in
            let title = shootout.playerScore > shootout.opponentScore ? "You Win!" : "You Lose!"
            let message = "Final Score: \(shootout.playerScore) - \(shootout.opponentScore)\nDifficulty: \(shootout.difficulty.rawValue)"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}
