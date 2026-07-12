//
//  EditProfileViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import UIKit
import Combine
import SnapKit

class EditProfileViewController: UIViewController {

    private let viewModel: EditProfileViewModel
    private let coordinator: EditProfileCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var hasChanges: Bool {
        guard let user = viewModel.user else { return false }
        
        let newIsApplicant = userTypeSegmentControl.selectedSegmentIndex == 0
        
        return (firstNameTextField.text ?? "") != (user.firstName ?? "") ||
               (lastNameTextField.text ?? "") != (user.lastName ?? "") ||
               (userNameTextField.text ?? "") != user.username ||
               (emailTextField.text ?? "") != user.email ||
               newIsApplicant != user.isApplicant
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    private let changePhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "changePhoto".localized
        label.font = .systemFont(ofSize: 14)
        label.textColor = .primaryBlueContent
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private let userNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "username".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        return textField
    }()
    
    private let firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "firstName".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        
        return textField
    }()
    
    private let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "lastName".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "email".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.isEnabled = true
        
        return textField
    }()
    
    private let userTypeSegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["applicant".localized, "employer".localized])
        segment.selectedSegmentIndex = 0
        segment.backgroundColor = .white
        segment.selectedSegmentTintColor = .primaryBlueContent
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        return segment
        
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("save".localized, for: .normal)
        button.backgroundColor = .primaryBlueContent
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.isEnabled = false
        button.alpha = 0.6
        
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        
        return indicator
    }()
    
    init(viewModel: EditProfileViewModel, coordinator: EditProfileCoordinatorProtocol) {
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
    
    private func setupUI() {
        view.backgroundColor = .primaryBackground
        title = "editProfile".localized
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [avatarImageView, changePhotoLabel, userNameTextField, firstNameTextField, lastNameTextField, emailTextField, userTypeSegmentControl, saveButton] .forEach {
            contentView.addSubview($0)
        }
        
        saveButton.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {make in
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
        
        changePhotoLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        firstNameTextField.snp.makeConstraints { make in
            make.top.equalTo(changePhotoLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }

        lastNameTextField.snp.makeConstraints { make in
            make.top.equalTo(firstNameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }

        userNameTextField.snp.makeConstraints { make in
            make.top.equalTo(lastNameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }

        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(userNameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        userTypeSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(36)
        }
            
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(userTypeSegmentControl.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-24)
        }
            
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        userNameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        firstNameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        userTypeSegmentControl.addTarget(self, action: #selector(textFieldChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        changePhotoLabel.addGestureRecognizer(labelTap)
    }
    
    private func setupBindings() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let user = user else { return }
                self?.firstNameTextField.text = user.firstName
                self?.lastNameTextField.text = user.lastName
                self?.userNameTextField.text = user.username
                self?.emailTextField.text = user.email
                self?.userTypeSegmentControl.selectedSegmentIndex = user.isApplicant ? 0 : 1
            }
            .store(in: &cancellables)
        viewModel.$isSaving
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSaving in
                if isSaving {
                    self?.saveButton.isEnabled = false
                    self?.saveButton.setTitle("", for: .normal)
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.saveButton.isEnabled = true
                    self?.saveButton.setTitle("save".localized, for: .normal)
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
        viewModel.$saveSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                if success {
                    self?.coordinator.dismiss()
                }
            }
            .store(in: &cancellables)
    }

    @objc private func textFieldChanged() {
        updateSaveButtonState()
    }
    
    @objc private func saveTapped() {
        
        let newEmail = emailTextField.text ?? ""
        let currentEmail = viewModel.user?.email ?? ""
        let isEmailChanged = newEmail != currentEmail && !newEmail.isEmpty
        
        let isApplicant = userTypeSegmentControl.selectedSegmentIndex == 0
        
        if isEmailChanged {
                viewModel.newEmail = newEmail
                viewModel.sendVerificationCode(to: currentEmail)
                showVerificationAlert()
                return
            }
        viewModel.updateProfile(
            username: userNameTextField.text ?? "",
            firstName: firstNameTextField.text ?? "",
            lastName: lastNameTextField.text ?? "",
            isApplicant: isApplicant
        )
        coordinator.dismiss()
        
    }
    
    @objc private func avatarTapped() {
        
    }
    
    private func updateSaveButtonState() {
        guard let user = viewModel.user else {
                saveButton.isEnabled = false
                saveButton.alpha = 0.6
                return
            }

            let isUsernameValid = !(userNameTextField.text?.isEmpty ?? true)
            saveButton.isEnabled = hasChanges && isUsernameValid
            saveButton.alpha = saveButton.isEnabled ? 1 : 0.6
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showVerificationAlert() {
        let alert = UIAlertController(
            title: "confirmEmailChange".localized,
            message: "codeSentToOldEmail".localized + " \(viewModel.user?.email ?? "")",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "enterCode".localized
            textField.keyboardType = .numberPad
            textField.font = .systemFont(ofSize: 20, weight: .medium)
            textField.textAlignment = .center
        }
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        
        alert.addAction(UIAlertAction(title: "confirm".localized, style: .default) { [weak self] _ in
            guard let code = alert.textFields?.first?.text, !code.isEmpty else {
                        self?.showErrorAlert(message: "enterCode".localized)
                        return
                    }
                    
                    // ✅ Сначала проверяем код
                    self?.viewModel.verifyCodeAndSave(code) { [weak self] success in
                        if success {
                            let isApplicant = self?.userTypeSegmentControl.selectedSegmentIndex == 0

                            // ✅ После успешной верификации — сохраняем остальные поля
                            self?.viewModel.updateProfile(
                                username: self?.userNameTextField.text ?? "",
                                firstName: self?.firstNameTextField.text ?? "",
                                lastName: self?.lastNameTextField.text ?? "",
                                isApplicant: isApplicant
                            )
                            self?.coordinator.dismiss()
                        }
                    }
                })
        
        alert.addAction(UIAlertAction(title: "resendCode".localized, style: .default) { [weak self] _ in
            guard let email = self?.viewModel.user?.email else { return }
                    self?.viewModel.sendVerificationCode(to: email)
                    self?.dismiss(animated: true) {
                        self?.showVerificationAlert()  // ← показываем новый
                    }
                })
        
        present(alert, animated: true)
    }
}
