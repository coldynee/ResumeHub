//
//  ItemEditViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import UIKit
import Combine
import SnapKit
import FirebaseFirestore

enum EditItemType {
    case resume(Resume)
    case vacancy(Vacancy)
}

final class ItemEditViewController: UIViewController {
    
    private let userManager: UserManagerProtocol
    
    private let item: EditItemType
    private let coordinator: ItemEditCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "title".localized
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
        label.text = "descriptionPlaceholder".localized
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
    
    // Для резюме
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
        textField.placeholder = "skillsCommaSeparated".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        return textField
    }()
    
    // Для вакансий
    private let companyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "companyName".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        return textField
    }()
    
    private let requirementsTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "requirements".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        return textField
    }()
    
    private let locationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "location".localized
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("save".localized, for: .normal)
        button.backgroundColor = .primaryBlueContent
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("delete".localized, for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    // MARK: - Init
    init(item: EditItemType, coordinator: ItemEditCoordinatorProtocol, userManager: UserManagerProtocol) {
        self.item = item
        self.coordinator = coordinator
        self.userManager = userManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
        configureFields()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "edit".localized
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Базовые поля
        [titleTextField, descriptionTextView, salaryTextField, saveButton, deleteButton].forEach {
            contentView.addSubview($0)
        }
        
        descriptionTextView.addSubview(descriptionPlaceholderLabel)
        saveButton.addSubview(activityIndicator)
        
        // Добавляем поля в зависимости от типа
        switch item {
        case .resume:
            [experienceTextField, skillsTextField].forEach {
                contentView.addSubview($0)
            }
        case .vacancy:
            [companyTextField, requirementsTextField, locationTextField].forEach {
                contentView.addSubview($0)
            }
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
        
        let sideInset: CGFloat = 24
        let spacing: CGFloat = 16
        var lastView: UIView?
        
        // Title
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(50)
        }
        lastView = titleTextField
        
        // Description
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(150)
        }
        lastView = descriptionTextView
        
        descriptionPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView).offset(8)
            make.leading.equalTo(descriptionTextView).offset(8)
            make.trailing.equalTo(descriptionTextView).inset(8)
        }
        
        // Salary
        salaryTextField.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(50)
        }
        lastView = salaryTextField
        
        // Дополнительные поля в зависимости от типа
        switch item {
        case .resume:
            experienceTextField.snp.makeConstraints { make in
                make.top.equalTo(lastView!.snp.bottom).offset(spacing)
                make.leading.trailing.equalToSuperview().inset(sideInset)
                make.height.equalTo(50)
            }
            lastView = experienceTextField
            
            skillsTextField.snp.makeConstraints { make in
                make.top.equalTo(lastView!.snp.bottom).offset(spacing)
                make.leading.trailing.equalToSuperview().inset(sideInset)
                make.height.equalTo(50)
            }
            lastView = skillsTextField
            
        case .vacancy:
            companyTextField.snp.makeConstraints { make in
                make.top.equalTo(lastView!.snp.bottom).offset(spacing)
                make.leading.trailing.equalToSuperview().inset(sideInset)
                make.height.equalTo(50)
            }
            lastView = companyTextField
            
            requirementsTextField.snp.makeConstraints { make in
                make.top.equalTo(lastView!.snp.bottom).offset(spacing)
                make.leading.trailing.equalToSuperview().inset(sideInset)
                make.height.equalTo(50)
            }
            lastView = requirementsTextField
            
            locationTextField.snp.makeConstraints { make in
                make.top.equalTo(lastView!.snp.bottom).offset(spacing)
                make.leading.trailing.equalToSuperview().inset(sideInset)
                make.height.equalTo(50)
            }
            lastView = locationTextField
        }
        
        // Save Button
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(50)
        }
        lastView = saveButton
        
        // Delete Button
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        [titleTextField, salaryTextField, experienceTextField, skillsTextField,
         companyTextField, requirementsTextField, locationTextField].forEach {
            $0.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        // Подписка на изменения (можно добавить позже)
    }
    
    // MARK: - Configure
    private func configureFields() {
        descriptionTextView.delegate = self
        
        switch item {
        case .resume(let resume):
            titleTextField.text = resume.title
            descriptionTextView.text = resume.description
            descriptionPlaceholderLabel.isHidden = !resume.description.isEmpty
            salaryTextField.text = resume.salary != nil ? "\(resume.salary!)" : ""
            experienceTextField.text = resume.experience
            skillsTextField.text = resume.skills.joined(separator: ", ")
            
            companyTextField.isHidden = true
            requirementsTextField.isHidden = true
            locationTextField.isHidden = true
            
        case .vacancy(let vacancy):
            titleTextField.text = vacancy.title
            descriptionTextView.text = vacancy.description
            descriptionPlaceholderLabel.isHidden = !vacancy.description.isEmpty
            salaryTextField.text = vacancy.salary != nil ? "\(vacancy.salary!)" : ""
            companyTextField.text = vacancy.companyName
            requirementsTextField.text = vacancy.requirements.joined(separator: ", ")
            locationTextField.text = vacancy.location
            
            experienceTextField.isHidden = true
            skillsTextField.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc private func textFieldChanged() {
        // Можно добавить валидацию
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "fillAllFields".localized)
            return
        }
        
        var updatedData: [String: Any] = [:]
        
        switch item {
        case .resume(let resume):
            let skills = skillsTextField.text?
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty } ?? []
            
            updatedData = [
                "title": title,
                "description": descriptionTextView.text,
                "salary": Int(salaryTextField.text ?? "") ?? 0,
                "experience": experienceTextField.text ?? "",
                "skills": skills,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            let db = Firestore.firestore()
            db.collection(FirestoreCollections.resumes)
                .document(resume.id!)
                .updateData(updatedData) { [weak self] error in
                    if let error = error {
                        self?.showAlert(message: error.localizedDescription)
                    } else {
                        self?.coordinator.dismiss()
                    }
                }
            
        case .vacancy(let vacancy):
            let requirements = requirementsTextField.text?
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty } ?? []
            
            updatedData = [
                "title": title,
                "companyName": companyTextField.text ?? "",
                "description": descriptionTextView.text,
                "salary": Int(salaryTextField.text ?? "") ?? 0,
                "requirements": requirements,
                "location": locationTextField.text ?? "",
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            let db = Firestore.firestore()
            db.collection(FirestoreCollections.vacancies)
                .document(vacancy.id!)
                .updateData(updatedData) { [weak self] error in
                    if let error = error {
                        self?.showAlert(message: error.localizedDescription)
                    }
                    if let nav = self?.navigationController {
                        if let myItemsVC = nav.viewControllers.first(where: { $0 is MyItemsViewController }) as? MyItemsViewController {
                            nav.popToViewController(myItemsVC, animated: true)
                            myItemsVC.viewModel.loadItems()
                        } else {
                            nav.popViewController(animated: true)
                            
                        }
                    }
                }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "delete".localized,
            message: "deleteConfirmation".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive) { [weak self] _ in
            self?.deleteItem()
        })
        present(alert, animated: true)
    }
    
    private func deleteItem() {
        print("🗑️ deleteItem вызван")
        print("🔍 userManager = \(userManager)")
        print("🔍 currentUser = \(userManager.currentUser?.id ?? "nil")")
        let db = Firestore.firestore()
        guard let userId = userManager.currentUser?.id else {
            print("❌ userId = nil")
            showAlert(message: "userNotFound".localized)
            return
        }
        print("✅ userId = \(userId)")
        let docRef: DocumentReference
        let itemName: String
        
        switch item {
        case .resume(let resume):
            docRef = db.collection(FirestoreCollections.resumes).document(resume.id!)
            itemName = "resume".localized
        case .vacancy(let vacancy):
            docRef = db.collection(FirestoreCollections.vacancies).document(vacancy.id!)
            itemName = "vacancy".localized
        }
        
        // Показываем индикатор загрузки
        activityIndicator.startAnimating()
        deleteButton.isEnabled = false
        
        // Используем транзакцию для безопасного удаления
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                document = try transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // Проверяем, что документ существует
            guard let data = document.data(),
                  let docUserId = data["userId"] as? String else {
                let error = NSError(domain: "AppError", code: 404,
                                    userInfo: [NSLocalizedDescriptionKey: "itemNotFound".localized])
                errorPointer?.pointee = error
                return nil
            }
            
            // Проверяем, что документ принадлежит текущему пользователю
            guard docUserId == userId else {
                let error = NSError(domain: "AppError", code: 403,
                                    userInfo: [NSLocalizedDescriptionKey: "noPermission".localized])
                errorPointer?.pointee = error
                return nil
            }
            
            // Удаляем документ
            transaction.deleteDocument(docRef)
            return nil
            
        }) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.deleteButton.isEnabled = true
                
                if let error = error {
                    self?.showAlert(message: error.localizedDescription)
                } else {
                    // Успешное удаление — возвращаемся к списку
                    if let nav = self?.navigationController {
                        if let myItemsVC = nav.viewControllers.first(where: { $0 is MyItemsViewController }) as? MyItemsViewController {
                            nav.popToViewController(myItemsVC, animated: true)
                            myItemsVC.viewModel.loadItems()
                        } else {
                            nav.popViewController(animated: true)
                            
                        }
                    }
                }
            }
        }
    }

}

// MARK: - UITextViewDelegate
extension ItemEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
}
