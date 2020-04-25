//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by t19960804 on 4/18/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    var episode: Episode! {
        didSet {
            //Date to Custom String
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd,yyyy"
            pubDateLabel.text = formatter.string(from: episode.pubDate)
            
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            
            if let urlString = episode.imageURL {
                episodeImageView.sd_setImage(with: URL(string: urlString))
            }
        }
    }
    let episodeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        return iv
    }()
    let pubDateLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 18)
        lb.textColor = .purple
        return lb
    }()
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .boldSystemFont(ofSize: 22)
        lb.numberOfLines = 2
        return lb
    }()
    let descriptionLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 16)
        lb.textColor = .lightGray
        lb.numberOfLines = 2
        return lb
    }()
    lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [pubDateLabel,
                                                titleLabel,
                                                descriptionLabel])
        sv.axis = .vertical
        sv.spacing = 6
        return sv
    }()
    lazy var hStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [episodeImageView,vStackView])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 10
        return sv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(hStackView)
        hStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        hStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        hStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        hStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        episodeImageView.heightAnchor.constraint(equalTo: hStackView.heightAnchor, multiplier: 1).isActive = true
        episodeImageView.widthAnchor.constraint(equalTo: episodeImageView.heightAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
