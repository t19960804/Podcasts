//
//  FavoritesCell.swift
//  Podcasts
//
//  Created by t19960804 on 9/5/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class FavoritesCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .orange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
