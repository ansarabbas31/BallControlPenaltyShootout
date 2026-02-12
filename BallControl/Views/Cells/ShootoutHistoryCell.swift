import UIKit

final class ShootoutHistoryCell: UITableViewCell {
    
    static let identifier = "ShootoutHistoryCell"
    
    private let resultBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let difficultyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roundsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(resultBadge)
        contentView.addSubview(scoreLabel)
        contentView.addSubview(resultLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(difficultyLabel)
        contentView.addSubview(roundsLabel)
        
        NSLayoutConstraint.activate([
            resultBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            resultBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            resultBadge.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            resultBadge.widthAnchor.constraint(equalToConstant: 6),
            
            scoreLabel.leadingAnchor.constraint(equalTo: resultBadge.trailingAnchor, constant: 12),
            scoreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            resultLabel.leadingAnchor.constraint(equalTo: scoreLabel.trailingAnchor, constant: 8),
            resultLabel.firstBaselineAnchor.constraint(equalTo: scoreLabel.firstBaselineAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: resultBadge.trailingAnchor, constant: 12),
            dateLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 3),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            difficultyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            difficultyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            roundsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            roundsLabel.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 2)
        ])
    }
    
    func configure(with shootout: PenaltyShootout) {
        scoreLabel.text = "\(shootout.playerScore) - \(shootout.opponentScore)"
        resultLabel.text = shootout.resultText
        difficultyLabel.text = shootout.difficulty.rawValue
        
        let totalRounds = max(shootout.playerShots.count, shootout.opponentShots.count)
        roundsLabel.text = "\(totalRounds) rounds"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        dateLabel.text = formatter.string(from: shootout.date)
        
        let isWin = shootout.playerScore > shootout.opponentScore
        resultBadge.backgroundColor = isWin ? .systemGreen : .systemRed
        resultLabel.textColor = isWin ? .systemGreen : .systemRed
        scoreLabel.textColor = .label
    }
}
