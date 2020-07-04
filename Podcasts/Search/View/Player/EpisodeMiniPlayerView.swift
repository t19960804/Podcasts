//
//  EpisodeMiniPlayerView.swift
//  Podcasts
//
//  Created by t19960804 on 7/4/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

protocol EpisodeMiniPlayerViewDelegate: class {
    func handlePlayerControl()
    func cancelMiniPlayerView()
}
class EpisodeMiniPlayerView: UIView {
    static let height: CGFloat = 70
    var episode: Episode! {
        didSet {
            if let url = URL(string: episode.imageURL ?? "") {
                imageView.sd_setImage(with: url)
            }
            titleLabel.text = episode.title
        }
    }
    weak var delegate: EpisodeMiniPlayerViewDelegate?
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "This is just for a test, don't worry, Mother Fucker"
        lb.numberOfLines = 1
        lb.font = .systemFont(ofSize: 18)
        return lb
    }()
    let playerControlButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handlePlayerControl), for: .touchUpInside)
        return btn
    }()
    let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        btn.tintColor = .black
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(handleCancelMiniPlayerView), for: .touchUpInside)
        return btn
    }()
    lazy var hStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageView,
                                                titleLabel,
                                                playerControlButton,
                                                UIView(),
                                                UIView(),
                                                UIView(),
                                                cancelButton])
        sv.axis = .horizontal
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alignment = .center
        sv.spacing = 7
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        layer.shadowOpacity = 0.1
        addSubview(hStackView)
        hStackView.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        hStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        hStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        hStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7).isActive = true
        
        
        playerControlButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        playerControlButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        cancelButton.heightAnchor.constraint(equalTo: playerControlButton.heightAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: playerControlButton.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
    }
    @objc fileprivate func handlePlayerControl(){
        delegate?.handlePlayerControl()
    }
    @objc fileprivate func handleCancelMiniPlayerView(){
        delegate?.cancelMiniPlayerView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
