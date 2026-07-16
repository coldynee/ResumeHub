//
//  MyItemsViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import UIKit
import Combine
import SnapKit

class MyItemsViewController: UIViewController {
    
    let viewModel: MyItemsViewModel
    private let coordinator: MyItemsCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseIdentifier)
        tableView.rowHeight = 80
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "noItems".localized
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    init(viewModel: MyItemsViewModel, coordinator: MyItemsCoordinatorProtocol) {
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
        viewModel.loadItems()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.isApplicant ? "myResumes".localized : "myVacancies".localized
        
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
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupBindings() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.tableView.reloadData()
                self?.emptyStateLabel.isHidden = !items.isEmpty
                self?.tableView.isHidden = items.isEmpty
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
    }
}
    
extension MyItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseIdentifier, for: indexPath)
        let item = viewModel.items[indexPath.row]
        
        if let resume = item as? Resume {
            cell.textLabel?.text = resume.title
            cell.detailTextLabel?.text = "\(resume.experience) лет опыта"
            cell.imageView?.image = UIImage(systemName: "doc.text")
            cell.imageView?.tintColor = .primaryBlueContent
        } else if let vacancy = item as? Vacancy {
            cell.textLabel?.text = vacancy.title
            cell.detailTextLabel?.text = vacancy.companyName
            cell.imageView?.image = UIImage(systemName: "briefcase")
            cell.imageView?.tintColor = .primaryBlueContent
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.items[indexPath.row]
        
        if let resume = item as? Resume {
            coordinator.showResumeDetail(resume)
        } else if let vacancy = item as? Vacancy {
            coordinator.showVacancyDetail(vacancy)
        }
    }
}
