//
//  FavoritesCell.swift
//  Podcasts
//
//  Created by t19960804 on 9/5/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

protocol FavoritesCellDelegate {
    func longPressOnFavoritesCell(cell: UICollectionViewCell)
}
class FavoritesCell: UICollectionViewCell {
    static let cellID = "Cell"

    let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"), contentMode: .scaleToFill)
    let titleLabel = UILabel(text: "Lests Build That App", font: .boldSystemFont(ofSize: 16), numberOfLines: 1)
    let artistNameLabel = UILabel(text: "Brian Voong", font: .systemFont(ofSize: 14),textColor: .gray, numberOfLines: 1)
    lazy var vStackView = UIStackView(subViews: [imageView,
                                                 titleLabel,
                                                 artistNameLabel], axis: .vertical)
    var delegate: FavoritesCellDelegate?
    var podcast: Podcast? {
        didSet {
            imageView.sd_setImage(with: URL(string: podcast?.artworkUrl600 ?? ""))
            titleLabel.text = podcast?.trackName
            artistNameLabel.text = podcast?.artistName
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.heightAnchor.constraint(lessThanOrEqualTo: imageView.widthAnchor).isActive = true
        addSubview(vStackView)
        vStackView.fillSuperview()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPress)
    }
    @objc func handleLongPress(){
        delegate?.longPressOnFavoritesCell(cell: self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
