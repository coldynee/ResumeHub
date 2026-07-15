//
//  ProfileViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import UIKit
import Combine
import SnapKit

final class ProfileViewController: UIViewController {
    
    let viewModel: ProfileViewModel
    private let coordinator: ProfileCoordinatorProtocol
    private var cancellabes = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person.circle.fill") //ЗАГЛУШКА
        imageView.tintColor = .systemGray3
        
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        
        return label
    }()
    
    private let menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.backgroundColor = .secondarySystemBackground
        stackView.layer.cornerRadius = 12
        stackView.clipsToBounds = true
        
        return stackView
    }()
    
    private static func createMenuItem(title: String, icon: String, isDestructive: Bool = false) -> UIButton {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: icon)
        config.imagePadding = 12
        config.title = title
        config.baseForegroundColor = isDestructive ? .systemRed : .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        return button
    }
    
    private let editProfileButton = createMenuItem(title: "editProfile".localized, icon: "pencil")
    private let myResumesButton = createMenuItem(title: "myResumes".localized, icon: "doc.text")
    private let settingsButton = createMenuItem(title: "settings".localized, icon: "gear")
    private let logoutButton = createMenuItem(title: "logout".localized, icon: "rectangle.portait.and.arrow.right", isDestructive: true)
    
    var onEditProfileTapped: (() -> Void)?
    var onMyResumesTapped: (() -> Void)?
    var onSettingsTapped: (() -> Void)?
    var onLogoutTapped: (() -> Void)?
    
    
    init(viewModel: ProfileViewModel, coordinator: ProfileCoordinatorProtocol) {
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
        setupConstraints()
        setupActions()
        setupBindings()
        viewModel.loadProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadProfile()
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackground
        title = "profile".localized
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [avatarImageView, nameLabel, emailLabel, menuStackView].forEach {
            contentView.addSubview($0)
        }
        
        [editProfileButton, myResumesButton, settingsButton, logoutButton].forEach {
            menuStackView.addArrangedSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        menuStackView.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func setupActions() {
        editProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        myResumesButton.addTarget(self, action: #selector(myResumesTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settignsTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    @objc private func editProfileTapped() {
        coordinator.showEditProfile()
    }
    
    @objc private func myResumesTapped() {
        
    }
    
    @objc private func settignsTapped() {
        coordinator.showSettings()
    }
    
    @objc private func logoutTapped() {
        showLogoutConfirmation()
    }
    
    private func setupBindings() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let user = user else { return }
                self?.nameLabel.text = user.fullName
                self?.emailLabel.text = user.email
                print("👤 user загружен: \(user.username), avatarURL: \(user.avatarURL ?? "nil")")

                self?.loadAvatar(from: user.avatarURL)
            }
            .store(in: &cancellabes)
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(title: "logout".localized, message: "logoutConfirmation".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "logout".localized, style: .destructive) { [weak self] _ in
            print("🔴 Нажата кнопка Logout")
            self?.viewModel.logout()
            self?.coordinator.didLogout()
        })
        present(alert, animated: true)
    }
    
    private func loadAvatar(from url: String?) {
        print("🖼️ loadAvatar вызван с url: \(url ?? "nil")")

        guard let urlString = url, let url = URL(string: urlString) else {
            print("❌ Неверный URL или nil, ставим заглушку")

            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray3
            return
        }
        print("🖼️ Загружаем аватар по URL: \(urlString)")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.avatarImageView.image = image
                    self?.avatarImageView.contentMode = .scaleAspectFill
                } else {
                    self?.avatarImageView.image = UIImage(systemName: "person.circle.fill")
                                    self?.avatarImageView.tintColor = .systemGray3
                }
            }
        }.resume()
    }
}
