//
//  PetDetailCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class PetDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    func configure(petItem: PetStableItem) {
        if let key = petItem.pet?.key {
            if petItem.trained != 0 {
                imageView.setImagewith(name: "Pet-\(key)")
            } else {
                ImageManager.getImage(name: "Pet-\(key)") {[weak self] (image, _) in
                    self?.imageView.image = image?.withRenderingMode(.alwaysTemplate)
                }
            }
        }
        if petItem.trained == -1 {
            imageView.alpha = 0.3
        } else {
            imageView.alpha = 1.0
        }
        if petItem.pet?.type != " " && petItem.trained > 0 && petItem.mountOwned == false {
            progressView.isHidden = false
            progressView.progress = Float(petItem.trained) / 50.0
        } else {
            progressView.isHidden = true
        }
    }
}
