//
//  FavoritesViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import UIKit
import Combine
import SnapKit

final class FavoritesViewController: UIViewController {
    
    private let viewModel: FavoritesViewModel
    private let coordinator: FavoritesCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FeedCell.self, forCellReuseIdentifier: FeedCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "emptyFavorites".localized
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    init(viewModel: FavoritesViewModel, coordinator: FavoritesCoordinatorProtocol) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupBindings()
        viewModel.loadFavorites()
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackground
        title = "favorites".localized
        tableView.backgroundColor = .primaryBackground
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(activityIndicator)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        refreshControl.addTarget(self, action: #selector(refreshFavorites), for: .valueChanged)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.tableView.reloadData()
                self?.emptyStateLabel.isHidden = !items.isEmpty
                self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message, !message.isEmpty {
                    self?.showErrorAlert(message: message)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func refreshFavorites() {
        viewModel.loadFavorites()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
}

    // MARK: - UITableView
extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.reuseIdentifier, for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        
        let item = viewModel.items[indexPath.row]
        
        // Конвертируем FavoriteItem в FeedItem для отображения
        let feedItem = FeedItem(
            id: item.id,
            type: item.type,
            userId: "",
            title: item.title,
            description: "",
            salary: nil,
            createdAt: Date(),
            username: "",
            companyName: nil,
            location: nil,
            experience: nil,
            skills: nil
        )
        cell.configure(with: feedItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.items[indexPath.row]
        
        switch item {
        case .resume(let resume):
            coordinator.showResumeDetail(resume)
        case .vacancy(let vacancy):
            coordinator.showVacancyDetail(vacancy)
        }
    }
}
