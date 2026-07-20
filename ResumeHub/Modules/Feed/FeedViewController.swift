//
//  FeedViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import UIKit
import Combine
import SnapKit
import FirebaseFirestore

final class FeedViewController: UIViewController {
    
    private let viewModel: FeedViewModel
    private let coordinator: FeedCoordinatorProtocol
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
        label.text = "emptyFeed".localized
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    init(viewModel: FeedViewModel, coordinator: FeedCoordinatorProtocol) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.removeObject(forKey: "hasShownFeedRoleToast")
        setupUI()
        setupTableView()
        setupBindings()
        viewModel.loadFeed()
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewModel.stopListening()
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackground
        title = viewModel.isApplicant ? "vacancies".localized : "resumes".localized
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
        
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        print("✅ tableView.delegate = \(tableView.delegate != nil ? "✅" : "❌")")
        print("✅ tableView.dataSource = \(tableView.dataSource != nil ? "✅" : "❌")")
    }
    
    private func setupBindings() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                print("📱 tableView получил \(items.count) элементов")
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
        print("📦 cancellables count: \(cancellables.count)")
    }
    @objc private func refreshFeed() {
        viewModel.loadFeed()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
    
    private func showRoleExplanationToast() {
//        let hasShownToast = UserDefaults.standard.bool(forKey: "hasShownFeedRoleToast")
//        guard !hasShownToast else { return }
        
        let isApplicant = viewModel.isApplicant
        
        let message = isApplicant
        ? "applicantToast".localized
        : "employeerToast".localized
        
        let icon = isApplicant
        ? UIImage(systemName: "person.fill")
        : UIImage(systemName: "building.2.fill")
        
        ToastPresenter.shared.showToast(
            in: view,
            icon: icon,
            iconColor: .primaryBlueContent,
            message: message,
            duration: 8.0,
            position: .top,
            onClose: { [weak self] in
                // Пользователь закрыл Toast вручную
                self?.markToastAsShown()
            }
        )
        
        // Отмечаем, что Toast показан
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
            self?.markToastAsShown()
        }
    }
    private func markToastAsShown() {
        UserDefaults.standard.set(true, forKey: "hasShownFeedRoleToast")
    }
    private func setupNavigationBar() {
        let titleView = UIView()
            
            // Основной заголовок
            let titleLabel = UILabel()
            titleLabel.text = viewModel.isApplicant ? "Вакансии" : "Резюме"
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            titleLabel.textColor = .label
            
            // Подзаголовок с ролью
            let roleLabel = UILabel()
            let roleText = viewModel.isApplicant ? "Вы соискатель ▼" : "Вы работодатель ▼"
            roleLabel.text = roleText
            roleLabel.font = .systemFont(ofSize: 12, weight: .medium)
            roleLabel.textColor = .primaryBlueContent
            roleLabel.isUserInteractionEnabled = true
            
            // Добавляем tap gesture на роль
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(roleLabelTapped))
            roleLabel.addGestureRecognizer(tapGesture)
            
            // Добавляем в стек
            let stackView = UIStackView(arrangedSubviews: [titleLabel, roleLabel])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 2
            
            titleView.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            navigationItem.titleView = titleView
    }
    
    @objc private func roleLabelTapped() {
        showRoleExplanationToast()
    }
}


extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📊 numberOfRowsInSection: \(viewModel.items.count)")
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🔨 cellForRowAt: \(indexPath.row)")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.reuseIdentifier, for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.items[indexPath.row]
        
        if item.type == "resume" {
            let resume = Resume(
                id: item.id,
                userId: item.userId,
                title: item.title,
                description: item.description,
                salary: item.salary,
                experience: item.experience ?? "",
                skills: item.skills ?? [],
                createdAt: Timestamp(date: item.createdAt),
                updatedAt: Timestamp(date: item.createdAt)
            )
            coordinator.showResumeDetail(resume)
        } else {
            let vacancy = Vacancy(
                id: item.id,
                userId: item.userId,
                companyName: item.companyName ?? "",
                title: item.title,
                description: item.description,
                salary: item.salary,
                requirements: [],
                location: item.location ?? "",
                createdAt: Timestamp(date: item.createdAt),
                updatedAt: Timestamp(date: item.createdAt)
            )
            coordinator.showVacancyDetail(vacancy)
        }
    }
}

