//
//  LaunchViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import UIKit

final class LaunchViewController: UIViewController {
    
    // MARK: - Properties
    private let mainView = LaunchView()
    private let coordinator: LaunchCoordinatorProtocol
    
    // MARK: - Init
    init(coordinator: LaunchCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Запускаем анимацию
        mainView.startAnimation { [weak self] in
            // После анимации переходим к авторизации
            self?.coordinator.showAuthorization()
        }
    }
}
