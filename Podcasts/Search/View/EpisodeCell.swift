//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by t19960804 on 4/18/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    var episode: EpisodeViewModel! {
        didSet {
            pubDateLabel.text = episode.publishDateString
            titleLabel.text = episode.title
            durationLabel.text = episode.duration
            episodeImageView.sd_setImage(with: episode.imageUrl)
            
            if episode.isWaitingForDownload {
                self.durationLabel.text = "Waiting for download..."
                self.isUserInteractionEnabled = false
                self.contentView.backgroundColor = UIColor(white: 0.5, alpha: 0.2)
            }
            let downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
            let episodeWasDownloaded = downloadedEpisodes.contains(where: {
                $0.title == episode.title && $0.author == episode.author
            })
            downloadedImageView.isHidden = episodeWasDownloaded ? false : true
            audioPlayingContainerView.isHidden = episode.isPlaying ? false : true
        }
    }
    static let cellID = "EpisodeCell"

    let episodeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        iv.contentMode = .scaleToFill //填滿imageView，但圖片不會保持的比例
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
    let durationLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 16)
        lb.textColor = .lightGray
        lb.numberOfLines = 2
        return lb
    }()
    let downloadedImageView = UIImageView(image: UIImage(named: "cloudDownload")?.withRenderingMode(.alwaysTemplate))
    let audioPlayingImageView = UIImageView(image: UIImage(named: "audio")?.withRenderingMode(.alwaysTemplate), contentMode: .scaleToFill)
    let audioPlayingContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    lazy var imageAndLabelStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [downloadedImageView,
                                                durationLabel])
        sv.axis = .horizontal
        sv.spacing = 5
        return sv
    }()
    lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [pubDateLabel,
                                                titleLabel,
                                                imageAndLabelStackView])
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
        selectionStyle = .none
        downloadedImageView.tintColor = .purple
        audioPlayingImageView.tintColor = .white
        audioPlayingContainerView.isHidden = true
        setupConstraints()
    }
    fileprivate func setupConstraints(){
        //https://stackoverflow.com/questions/13123306/ios-what-is-superview-and-what-is-subviews
        addSubview(hStackView)
        episodeImageView.addSubview(audioPlayingContainerView)
        audioPlayingContainerView.addSubview(audioPlayingImageView)
        
        hStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        hStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        hStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        hStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        episodeImageView.heightAnchor.constraint(equalTo: hStackView.heightAnchor, multiplier: 1).isActive = true
        episodeImageView.widthAnchor.constraint(equalTo: episodeImageView.heightAnchor).isActive = true
        
        audioPlayingContainerView.fillSuperview()
        audioPlayingImageView.heightAnchor.constraint(equalTo: audioPlayingContainerView.heightAnchor, multiplier: 0.5).isActive = true
        audioPlayingImageView.widthAnchor.constraint(equalTo: audioPlayingContainerView.widthAnchor, multiplier: 0.5).isActive = true
        audioPlayingImageView.centerInSuperview()

        downloadedImageView.widthAnchor.constraint(equalTo: imageAndLabelStackView.widthAnchor, multiplier: 0.1).isActive = true
        downloadedImageView.heightAnchor.constraint(equalTo: imageAndLabelStackView.widthAnchor, multiplier: 0.1).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
