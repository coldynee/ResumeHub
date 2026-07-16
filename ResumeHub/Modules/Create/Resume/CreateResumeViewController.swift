//
//  CreateResumeViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import UIKit
import SnapKit
import Combine

final class CreateResumeViewController: UIViewController {
    private let viewModel: CreateResumeViewModel
    private let coordinator: CreateCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "resumeTitle".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.separator.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        return textView
    }()
    
    private let descriptionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = " descriptionPlaceholder".localized
        label.font = .systemFont(ofSize: 16)
        label.textColor = .placeholderText
        label.numberOfLines = 0
        
        return label
    }()
    
    private let salaryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "salary".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.keyboardType = .numberPad
        
        return textField
    }()
    
    private let experienceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "experienceYears".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.keyboardType = .numberPad
        
        return textField
    }()
    
    private let skillsTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "skills".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("createResume".localized, for: .normal)
        button.backgroundColor = .primaryBackgroundInversed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
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
    
    init(viewModel: CreateResumeViewModel, coordinator: CreateCoordinatorProtocol) {
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
        setupTextView()
        setupActions()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackground
        title = "createResume".localized
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleTextField, descriptionTextView, salaryTextField,
         experienceTextField, skillsTextField, saveButton].forEach {
            contentView.addSubview($0)
        }
        
        descriptionTextView.addSubview(descriptionPlaceholderLabel)
        saveButton.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let sideInset: CGFloat = 24
        let spacing: CGFloat = 16
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(50)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(150)
        }
        
        descriptionPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView).offset(8)
            make.leading.equalTo(descriptionTextView).offset(8)
            make.trailing.equalTo(descriptionTextView).inset(8)
        }
        
        salaryTextField.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(50)
        }
        
        experienceTextField.snp.makeConstraints { make in
            make.top.equalTo(salaryTextField.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(50)
        }
        
        skillsTextField.snp.makeConstraints { make in
            make.top.equalTo(experienceTextField.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(50)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(skillsTextField.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTextView() {
        descriptionTextView.delegate = self
    }
    
    private func setupActions() {
        [titleTextField, salaryTextField, experienceTextField, skillsTextField].forEach {
            $0.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.$isSaving
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSaving in
                if isSaving {
                    self?.saveButton.isEnabled = false
                    self?.saveButton.setTitle("", for: .normal)
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.saveButton.setTitle("createResume".localized, for: .normal)
                    self?.activityIndicator.stopAnimating()
                    self?.updateSaveButtonState()
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
                    self?.showSuccessAndClear()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showSuccessAndClear() {
        let alert = UIAlertController(
            title: "success".localized,
            message: "resumeCreated".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default) { [weak self] _ in
            self?.clearFields()
            self?.coordinator.dismiss()
        })
        present(alert, animated: true)
    }

    private func clearFields() {
        titleTextField.text = ""
        descriptionTextView.text = ""
        descriptionPlaceholderLabel.isHidden = false
        salaryTextField.text = ""
        experienceTextField.text = ""
        skillsTextField.text = ""
        updateSaveButtonState()
    }
    
    @objc private func textFieldChanged() {
        updateSaveButtonState()
    }
    
    @objc private func saveTapped() {
        let skills = skillsTextField.text?.components(separatedBy: ",").map {
            $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } ?? []
        
        viewModel.createResume(
            title: titleTextField.text ?? "",
            description: descriptionTextView.text,
            salary: Int(salaryTextField.text ?? ""),
            experience: experienceTextField.text ?? "",
            skills: skills
        )
    }
    
    private func updateSaveButtonState() {
        let isValid = !(titleTextField.text?.isEmpty ?? true) &&
        !(descriptionTextView.text.isEmpty) &&
        !(experienceTextField.text?.isEmpty ?? true)
        saveButton.isEnabled = isValid
        saveButton.alpha = isValid ? 1 : 0.6
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CreateResumeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden = !textView.text.isEmpty
        updateSaveButtonState()
    }
}
