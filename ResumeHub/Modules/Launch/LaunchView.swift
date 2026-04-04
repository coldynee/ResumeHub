//
//  LaunchView.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import UIKit
import SnapKit

final class LaunchView: UIView {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ResumeHub"
        label.font = .systemFont(ofSize: 40, weight: .heavy)
        label.textColor = .titleInversed
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "subtitle".localized
        label.font = .systemFont(ofSize: 26)
        label.textColor = .titleInversed
        label.textAlignment = .center
        label.sizeToFit()
        label.alpha = 0
        
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .primaryBlueContent
        indicator.hidesWhenStopped = true
        indicator.alpha = 0
        return indicator
    }()
    
    private let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBackgroundInversed
        view.layer.cornerRadius = 50
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.alpha = 0
        return view
    }()
    
    // MARK: - Properties for animation
    private var titleViewTopConstraint: Constraint?
    private let endOffset: CGFloat
    private let startOffset: CGFloat
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        let screenHeight = UIScreen.main.bounds.height
        let titleViewHeight = screenHeight / 3.5
        self.startOffset = -titleViewHeight - 50
        self.endOffset = 0
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .primaryBackground
        
        addSubview(titleView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        // ✅ Правильный способ — сохраняем constraint при создании
        titleView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3.5)
            // Сохраняем constraint top
            self.titleViewTopConstraint = make.top.equalToSuperview().offset(self.startOffset).constraint
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleView.snp.centerY).offset(20)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottomMargin).offset(10)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
            
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Animation
    
    func startAnimation(completion: @escaping () -> Void) {
        print("📍 Animation started")  // для отладки
        
        // Шаг 1: Появление titleView
        UIView.animate(withDuration: 0.3) {
            self.titleView.alpha = 1
        } completion: { _ in
            print("📍 TitleView appeared, now moving down")
            
            // Шаг 2: Опускание titleView
            // Обновляем constraint
            self.titleViewTopConstraint?.update(offset: self.endOffset)
            
            // Принудительно обновляем layout
            self.setNeedsLayout()
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1.1, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.layoutIfNeeded()
            } completion: { _ in
                print("📍 TitleView moved down")
                
                // Шаг 3: Появление titleLabel
                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 1
                } completion: { _ in
                    // Шаг 4: Появление subtitleLabel
                    UIView.animate(withDuration: 0.4) {
                        self.subtitleLabel.alpha = 1
                    } completion: { _ in
                        // Шаг 5: Появление индикатора
                        UIView.animate(withDuration: 0.3) {
                            self.activityIndicator.alpha = 1
                        }
                    }
                }
            }
        }
        
        // Запускаем индикатор
        activityIndicator.startAnimating()
        
        // Ждем и исчезаем
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("📍 Fading out")
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            } completion: { _ in
                completion()
            }
        }
    }
}
