//
//  SettingsViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 15.07.2026.
//

import UIKit
import SnapKit

class SettingsViewController: UIViewController {

    private let userManager: UserManagerProtocol
    private let coordinator: SettingsCoordinatorProtocol
    
    private let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.showsVerticalScrollIndicator = false
        
            return scrollView
    }()
    
    private let contentView = UIView()
    
    private let appearanceLabel: UILabel = {
        let label = UILabel()
        label.text = "appearance".localized
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let themeSegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: [
            "system".localized,
            "light".localized,
            "dark".localized
        ])
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    // MARK: - Notifications
    private let notificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "notifications".localized
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let notificationsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        return toggle
    }()
    
    // MARK: - Language
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.text = "language".localized
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let languageSegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Русский", "English"])
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    
    private let securityLabel: UILabel = {
        let label = UILabel()
        label.text = "security".localized
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let biometricsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        return toggle
    }()
    
    private let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "about".localized
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let developerLabel: UILabel = {
        let label = UILabel()
        label.text = "Разработчик: Никита Морозов"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    init(userManager: UserManagerProtocol, coordinator: SettingsCoordinatorProtocol) {
        self.userManager = userManager
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
        loadSavedSettings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "settings".localized
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [appearanceLabel, themeSegmentControl, notificationsLabel, notificationsSwitch, languageLabel,
         languageSegmentControl, securityLabel, biometricsSwitch, aboutLabel, developerLabel].forEach {
                    contentView.addSubview($0)
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
        
        let spacing: CGFloat = 16
        let sideInset: CGFloat = 24
        
        // Appearance
        appearanceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        themeSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(appearanceLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(40)
        }
        
        // Notifications
        notificationsLabel.snp.makeConstraints { make in
            make.top.equalTo(themeSegmentControl.snp.bottom).offset(32)
            make.leading.equalToSuperview().inset(sideInset)
        }
        
        notificationsSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(notificationsLabel)
            make.trailing.equalToSuperview().inset(sideInset)
        }
        
        // Language
        languageLabel.snp.makeConstraints { make in
            make.top.equalTo(notificationsLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        languageSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(languageLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(40)
        }
        
        // Security
        securityLabel.snp.makeConstraints { make in
            make.top.equalTo(languageSegmentControl.snp.bottom).offset(32)
            make.leading.equalToSuperview().inset(sideInset)
        }
        
        biometricsSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(securityLabel)
            make.trailing.equalToSuperview().inset(sideInset)
        }
        
        // About
        aboutLabel.snp.makeConstraints { make in
            make.top.equalTo(securityLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        
        developerLabel.snp.makeConstraints { make in
            make.top.equalTo(aboutLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func setupActions() {
        themeSegmentControl.addTarget(self, action: #selector(themeChanged), for: .valueChanged)
        notificationsSwitch.addTarget(self, action: #selector(notificationsChanged), for: .valueChanged)
        languageSegmentControl.addTarget(self, action: #selector(languageChanged), for: .valueChanged)
        biometricsSwitch.addTarget(self, action: #selector(biometricsChanged), for: .valueChanged)
    }
    
    private func loadSavedSettings() {
        // Тема
        let themeValue = UserDefaults.standard.integer(forKey: "selectedTheme")
        themeSegmentControl.selectedSegmentIndex = themeValue
        
        // Уведомления
        notificationsSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        // Язык
        let language = UserDefaults.standard.string(forKey: "appLanguage") ?? "ru"
        languageSegmentControl.selectedSegmentIndex = language == "ru" ? 0 : 1
        
        // Биометрия
        biometricsSwitch.isOn = UserDefaults.standard.bool(forKey: "biometricsEnabled")
    }
    
    @objc private func themeChanged() {
        let styles: [UIUserInterfaceStyle] = [.unspecified, .light, .dark]
        let selectedStyle = styles[themeSegmentControl.selectedSegmentIndex]
        
        UserDefaults.standard.set(themeSegmentControl.selectedSegmentIndex, forKey: "selectedTheme")
        applyTheme(selectedStyle)
    }
        
    @objc private func notificationsChanged() {
        let isEnabled = notificationsSwitch.isOn
        UserDefaults.standard.set(isEnabled, forKey: "notificationsEnabled")
        print("🔔 Уведомления: \(isEnabled ? "включены" : "выключены")")
            // TODO: Реальная настройка уведомлений
    }
        
    @objc private func languageChanged() {
        let language = languageSegmentControl.selectedSegmentIndex == 0 ? "ru" : "en"
        UserDefaults.standard.set(language, forKey: "appLanguage")
        print("🌍 Язык: \(language)")
            // TODO: Реальная смена языка
    }
    @objc private func biometricsChanged() {
        let isEnabled = biometricsSwitch.isOn
        UserDefaults.standard.set(isEnabled, forKey: "biometricsEnabled")
        print("🔒 Биометрия: \(isEnabled ? "включена" : "выключена")")
            // TODO: Реальная настройка биометрии
    }
        
    private func applyTheme(_ style: UIUserInterfaceStyle) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else { return }
            
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.overrideUserInterfaceStyle = style
        }
    }
    
}
