//
//  ChatListViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import UIKit

final class ChatListViewController: UIViewController {
    private let viewModel: ChatListViewModel
    private let coordinator: ChatCoordinatorProtocol
    
    init(viewModel: ChatListViewModel, coordinator: ChatCoordinatorProtocol) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "chat".localized
        
        let label = UILabel()
        label.text = "Чаты\n(в разработке)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
