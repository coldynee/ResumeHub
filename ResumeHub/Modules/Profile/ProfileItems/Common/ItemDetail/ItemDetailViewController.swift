//
//  ItemDetailViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import UIKit
import SnapKit

enum ItemType {
    case resume(Resume)
    case vacancy(Vacancy)
}

final class ItemDetailViewController: UIViewController {
    
    weak var parentCoordinator: MyItemsCoordinator?
    
    private var item: ItemType
    private var itemId: String?
    private let source: DetailSource
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let companyOrExperienceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let salaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .primaryBlueContent
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let skillsOrRequirementsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "pencil"),
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        button.tintColor = .primaryBlueContent
        return button
    }()
    
    private lazy var favoriteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        button.tintColor = .systemGray3
        return button
    }()
    
    
    init(item: ItemType, source: DetailSource) {
        self.item = item
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configure()
        setupNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackground
        
        scrollView.backgroundColor = .primaryBackground
        contentView.backgroundColor = .primaryBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, companyOrExperienceLabel, salaryLabel,
         descriptionLabel, skillsOrRequirementsLabel, locationLabel].forEach {
            contentView.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let sideInset: CGFloat = 24
        let spacing: CGFloat = 16
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        companyOrExperienceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        salaryLabel.snp.makeConstraints { make in
            make.top.equalTo(companyOrExperienceLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(salaryLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        skillsOrRequirementsLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(skillsOrRequirementsLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func configure() {
        switch item {
        case .resume(let resume):
            configureResume(resume)
        case .vacancy(let vacancy):
            configureVacancy(vacancy)
        }
    }
    
    private func configureResume(_ resume: Resume) {
        title = "resume".localized
        titleLabel.text = resume.title
        companyOrExperienceLabel.text = "experience".localized + ": \(resume.experience) лет"
        salaryLabel.text = resume.salary != nil ? "\(resume.salary!) ₽" : "salaryNotSpecified".localized
        descriptionLabel.text = resume.description
        skillsOrRequirementsLabel.text = "skills".localized + ": " + (resume.skills.isEmpty ? "notSpecified".localized : resume.skills.joined(separator: ", "))
        locationLabel.isHidden = true
        itemId = resume.id

    }
    
    private func setupNavigationBar() {
        switch source {
                case .myItems:
                    navigationItem.rightBarButtonItem = editButton

                case .feed, .favorites:
                    navigationItem.rightBarButtonItem = favoriteButton
                    updateFavoriteButtonState()
                }
    }
    
    func updateItem(with resume: Resume) {
        self.item = .resume(resume)
        configure()
    }

    func updateItem(with vacancy: Vacancy) {
        self.item = .vacancy(vacancy)
        configure()
    }
    
    @objc private func editTapped() {
        switch item {
        case .resume(let resume):
            parentCoordinator?.showResumeEdit(resume)
        case .vacancy(let vacancy):
            parentCoordinator?.showVacancyEdit(vacancy)
        }
    }
        
    private func configureVacancy(_ vacancy: Vacancy) {
        title = "vacancy".localized
        titleLabel.text = vacancy.title
        companyOrExperienceLabel.text = vacancy.companyName
        salaryLabel.text = vacancy.salary != nil ? "\(vacancy.salary!) ₽" : "salaryNotSpecified".localized
        descriptionLabel.text = vacancy.description
        skillsOrRequirementsLabel.text = "requirements".localized + ": " + (vacancy.requirements.isEmpty ? "notSpecified".localized : vacancy.requirements.joined(separator: ", "))
        locationLabel.text = "📍 " + vacancy.location
        locationLabel.isHidden = false
        itemId = vacancy.id

    }
    
    @objc private func favoriteButtonTapped() {
        guard let itemId = itemId else { return }
            
        // Определяем тип как Bool (true = resume, false = vacancy)
        let type: FavoriteType
        switch item {
        case .resume:
            type = .resume
        case .vacancy:
            type = .vacancy
        }
            
        let _ = FavoriteManager.shared.toggleFavorite(itemId: itemId, type: type) { [weak self] isFavorite in
            self?.updateFavoriteButtonState()
            print("❤️ \(isFavorite ? "Добавлено" : "Удалено") из избранного: \(itemId)")
        }
    }
        
    private func updateFavoriteButtonState() {
        guard let itemId = itemId else { return }
        
        let isFavorite = FavoriteManager.shared.isFavorite(itemId: itemId)
        
        let newButton = UIBarButtonItem(
                image: UIImage(systemName: isFavorite ? "heart.fill" : "heart"),
                style: .plain,
                target: self,
                action: #selector(favoriteButtonTapped)
            )
            newButton.tintColor = isFavorite ? .systemRed : .systemGray3
            
            navigationItem.rightBarButtonItem = newButton
    }
    
}
