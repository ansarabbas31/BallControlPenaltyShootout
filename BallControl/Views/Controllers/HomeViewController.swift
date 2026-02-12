import UIKit

final class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    private var tableView: UITableView!
    
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
        title = "Ball Control"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ShootoutHistoryCell.self, forCellReuseIdentifier: ShootoutHistoryCell.identifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 3 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 4
        default: return viewModel.recentShootouts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Start Penalty Shootout"
            content.image = UIImage(systemName: "play.circle.fill")
            content.imageProperties.tintColor = UIColor(hex: "#2E7D32")
            content.textProperties.font = .systemFont(ofSize: 18, weight: .bold)
            content.textProperties.color = UIColor(hex: "#2E7D32") ?? .systemGreen
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            let stats = viewModel.playerStats
            switch indexPath.row {
            case 0:
                content.text = "Shootouts Played"
                content.secondaryText = "\(stats.totalShootouts)"
            case 1:
                content.text = "Win Rate"
                content.secondaryText = String(format: "%.0f%%", stats.winRate)
            case 2:
                content.text = "Shot Accuracy"
                content.secondaryText = String(format: "%.0f%%", stats.accuracy)
            default:
                content.text = "Best Streak"
                content.secondaryText = "\(stats.bestStreak) wins"
            }
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ShootoutHistoryCell.identifier, for: indexPath) as! ShootoutHistoryCell
            cell.configure(with: viewModel.recentShootouts[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return "Your Stats"
        default: return "Recent Shootouts"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            tabBarController?.selectedIndex = 1
        }
    }
}
