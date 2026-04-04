//
//  UITextField.swift
//  ResumeHub
//
//  Created by Никита Морозов on 04.04.2026.
//

import Foundation
import UIKit

extension UITextField {
    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .primaryBlueContent
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        rightView = button
        rightViewMode = .always
    }
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        isSecureTextEntry.toggle()
        sender.isSelected.toggle()
    }
}
