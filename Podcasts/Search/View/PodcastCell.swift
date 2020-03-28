//
//  PodcastCell.swift
//  Podcasts
//
//  Created by t19960804 on 3/28/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class PodcastCell: UITableViewCell {
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artitstNameLabel.text = podcast.artistName
        }
    }
    let podcastImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .green
        iv.image = #imageLiteral(resourceName: "appicon")
        return iv
    }()
    let trackNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = .boldSystemFont(ofSize: 20)
        lb.numberOfLines = 2
        return lb
    }()
    let artitstNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 18)
        return lb
    }()
    let episodeCountLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 16)
        lb.textColor = .gray
        lb.text = "Episode Count"
        return lb
    }()
    lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [trackNameLabel,
                                                artitstNameLabel,
                                                episodeCountLabel])
        sv.spacing = 6
        sv.axis = .vertical
        return sv
    }()
    lazy var hStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [podcastImageView,
                                                vStackView])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 12
        //使用alignment時,沒有圖片的imageView會被壓縮到消失,記得放圖片
        //並且指定尺寸,避免被壓縮
        sv.alignment = .center
        return sv
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(hStackView)
        hStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        hStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        hStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        hStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
        podcastImageView.heightAnchor.constraint(equalTo: hStackView.heightAnchor, multiplier: 1).isActive = true
        podcastImageView.widthAnchor.constraint(equalTo: hStackView.heightAnchor, multiplier: 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
