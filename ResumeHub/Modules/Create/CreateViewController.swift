//
//  CreateViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 15.07.2026.
//

import UIKit

final class CreateViewController: UIViewController {

    private let coordinator: CreateCoordinatorProtocol
    
    init(coordinator: CreateCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        
    }

}
