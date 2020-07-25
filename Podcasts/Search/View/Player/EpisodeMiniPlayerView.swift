//
//  EpisodeMiniPlayerView.swift
//  Podcasts
//
//  Created by t19960804 on 7/4/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import LBTATools

protocol EpisodeMiniPlayerViewDelegate: class {
    func handlePlayerPauseAndPlay()
    func cancelMiniPlayerView()
    func handleMiniPlayerTapped()
    func handleMiniPlayerViewPanned(gesture: UIPanGestureRecognizer)
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
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"), contentMode: .scaleAspectFill)
    let titleLabel = UILabel(text: nil, font: .systemFont(ofSize: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
    let playerControlButton = UIButton(image: #imageLiteral(resourceName: "play"), tintColor: .black, target: self, action: #selector(handlePlayerPauseAndPlay))
    let cancelButton = UIButton(image: #imageLiteral(resourceName: "close"), tintColor: .black, target: self, action: #selector(handleCancelMiniPlayerView))
    lazy var hStackView = UIStackView(subViews: [imageView,
                                                 titleLabel,
                                                 playerControlButton,
                                                 UIView(),
                                                 UIView(),
                                                 UIView(),
                                                 cancelButton],
                                      axis: .horizontal,
                                      alignment: .center,
                                      spacing: 7)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        layer.shadowOpacity = 0.1
        cancelButton.imageView?.contentMode = .scaleAspectFit

        setupConstraints()
        addGesture()
    }
    fileprivate func addGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMiniPlayerTapped))
        addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMiniPlayerViewPanned(gesture:)))
        addGestureRecognizer(panGesture)
    }
    fileprivate func setupConstraints(){
        addSubview(hStackView)
        hStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 7, left: 15, bottom: 7, right: 15))
        
        playerControlButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .zero, size: .init(width: 32, height: 32))

        cancelButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .zero, size: .init(width: 32, height: 32))

        imageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .zero, size: .init(width: 45, height: 45))
    }
    @objc func handleMiniPlayerViewPanned(gesture: UIPanGestureRecognizer){
        delegate?.handleMiniPlayerViewPanned(gesture: gesture)
    }
    @objc func handleMiniPlayerTapped(){
        delegate?.handleMiniPlayerTapped()
    }
    @objc fileprivate func handlePlayerPauseAndPlay(){
        delegate?.handlePlayerPauseAndPlay()
    }
    @objc fileprivate func handleCancelMiniPlayerView(){
        delegate?.cancelMiniPlayerView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
