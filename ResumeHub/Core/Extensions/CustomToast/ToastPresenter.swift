//
//  ToastPresenter.swift
//  ResumeHub
//
//  Created by Никита Морозов on 20.07.2026.
//

import Foundation
import UIKit
import SnapKit

final class ToastPresenter {
    
    static let shared = ToastPresenter()
    private init() {}
    
    private var currentToast: CustomToastView?
    private var dismissTimer: Timer?
    
    func showToast(
        in view: UIView,
        icon: UIImage? = UIImage(systemName: "info.circle"),
        iconColor: UIColor = .systemBlue,
        message: String,
        duration: TimeInterval = 4.0,
        position: ToastPosition = .top,
        onClose: (() -> Void)? = nil
    ) {
        // Удаляем старый тост
        hideToast(animated: false)
        
        // Создаем новый тост
        let toast = CustomToastView()
        toast.configure(icon: icon, iconColor: iconColor, message: message)
        toast.onCloseTapped = { [weak self] in
            onClose?()
            self?.hideToast(animated: true)
        }
        
        // Добавляем в иерархию
        view.addSubview(toast)
        switch position {
        case .top:
            toast.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
            }
            
        case .bottom:
            toast.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
            }
            
        case .below(let anchor):
            guard let anchor = anchor else {
                // fallback на top
                toast.snp.makeConstraints { make in
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
                    make.leading.equalToSuperview().offset(16)
                    make.trailing.equalToSuperview().offset(-16)
                }
                break
            }
            
            toast.snp.makeConstraints { make in
                make.top.equalTo(anchor.snp.bottom).offset(8)
                make.leading.equalTo(anchor)
                make.trailing.equalTo(anchor)
            }
        }
        
        currentToast = toast
        
        // Анимация появления
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: -20)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            toast.alpha = 1
            toast.transform = .identity
        }
        
        // Автоматическое скрытие
        dismissTimer?.invalidate()
        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.hideToast(animated: true)
        }
    }
    
    func hideToast(animated: Bool = true) {
        guard let toast = currentToast else { return }
        
        dismissTimer?.invalidate()
        dismissTimer = nil
        
        let hideBlock = {
            toast.alpha = 0
            toast.transform = CGAffineTransform(translationX: 0, y: -20)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: hideBlock) { _ in
                toast.removeFromSuperview()
            }
        } else {
            hideBlock()
            toast.removeFromSuperview()
        }
        
        currentToast = nil
    }
}

enum ToastPosition {
    case top
    case bottom
    case below(UIView?) // Привязка к конкретному элементу
}
