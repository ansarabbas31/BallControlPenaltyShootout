import UIKit

final class StatisticsViewController: UIViewController {
    
    private let viewModel = StatisticsViewModel()
    private var tableView: UITableView!
    private var segmentedControl: UISegmentedControl!
    
    private var showStats = true
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        title = "Statistics"
        view.backgroundColor = .systemBackground
        
        segmentedControl = UISegmentedControl(items: ["Overview", "Zones", "History"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ShootoutHistoryCell.self, forCellReuseIdentifier: ShootoutHistoryCell.identifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func segmentChanged() {
        tableView.reloadData()
    }
}

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return 7
        case 1: return ShotZone.allCases.count
        default: return viewModel.completedShootouts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            let stats = viewModel.playerStats
            switch indexPath.row {
            case 0:
                content.text = "Total Shootouts"
                content.secondaryText = "\(stats.totalShootouts)"
            case 1:
                content.text = "Wins / Losses"
                content.secondaryText = "\(stats.wins) / \(stats.losses)"
            case 2:
                content.text = "Win Rate"
                content.secondaryText = String(format: "%.1f%%", stats.winRate)
            case 3:
                content.text = "Goals Scored"
                content.secondaryText = "\(stats.goals)"
            case 4:
                content.text = "Shot Accuracy"
                content.secondaryText = String(format: "%.1f%%", stats.accuracy)
            case 5:
                content.text = "Saves Made"
                content.secondaryText = "\(stats.saves)"
            default:
                content.text = "Best Win Streak"
                content.secondaryText = "\(stats.bestStreak)"
            }
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            let zoneStats = viewModel.zoneStats
            let zone = zoneStats[indexPath.row]
            content.text = zone.zone.displayName
            content.secondaryText = "Attempts: \(zone.attempts)  Goals: \(zone.goals)  Rate: \(String(format: "%.0f%%", zone.successRate))"
            content.secondaryTextProperties.font = .systemFont(ofSize: 12)
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ShootoutHistoryCell.identifier, for: indexPath) as! ShootoutHistoryCell
            cell.configure(with: viewModel.completedShootouts[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return "Player Statistics"
        case 1: return "Shot Zone Analysis"
        default: return "Shootout History"
        }
    }
}
