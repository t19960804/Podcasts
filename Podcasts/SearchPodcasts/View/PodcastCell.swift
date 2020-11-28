//
//  PodcastCell.swift
//  Podcasts
//
//  Created by t19960804 on 3/28/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artitstNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            let url = URL(string: podcast.artworkUrl600 ?? "")
            podcastImageView.sd_setImage(with: url)
        }
    }
    let podcastImageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
    let trackNameLabel = UILabel(font: .boldSystemFont(ofSize: 20), numberOfLines: 2)
    let artitstNameLabel = UILabel(font: .systemFont(ofSize: 18))
    let episodeCountLabel = UILabel(font: .systemFont(ofSize: 16), textColor: .gray)
    lazy var vStackView = UIStackView(subViews: [trackNameLabel,
                                                 artitstNameLabel,
                                                 episodeCountLabel],
                                      axis: .vertical,
                                      spacing: 6)
    
    lazy var hStackView = UIStackView(subViews: [podcastImageView,
                                                 vStackView],
                                      axis: .horizontal,
                                      alignment: .center,
                                      spacing: 12)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubview(hStackView)
        hStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 12, left: 12, bottom: 12, right: 12))
    }
    override func layoutSubviews() {
        //當layoutSubviews()執行時，它會依據 auto layout 的 constraint 排版 subviews
        super.layoutSubviews()
        //在super.layoutSubviews()執行後元件都依auto layout 的 constraint 得到位置大小
        podcastImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: hStackView.frame.size.height, height: hStackView.frame.size.height))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
