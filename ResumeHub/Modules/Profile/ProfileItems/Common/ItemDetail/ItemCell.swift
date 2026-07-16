//
//  ItemCell.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import UIKit

final class ItemCell: UITableViewCell {
    
    static let reuseIdentifier = "ItemCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        imageView?.contentMode = .scaleAspectFit
        imageView?.tintColor = .primaryBlueContent
        
        textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        detailTextLabel?.font = .systemFont(ofSize: 14)
        detailTextLabel?.textColor = .secondaryLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        imageView?.image = nil
    }
}
