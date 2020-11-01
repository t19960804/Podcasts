//
//  EpisodeMiniPlayerView.swift
//  Podcasts
//
//  Created by t19960804 on 7/4/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import LBTATools
import MarqueeLabel

protocol EpisodeMiniPlayerViewDelegate: class {
    func handlePlayerPauseAndPlay()
    func playNextTrack()
    func handleMiniPlayerTapped()
    func handleMiniPlayerViewPanned(gesture: UIPanGestureRecognizer)
}
class EpisodeMiniPlayerView: UIView {
    static let height: CGFloat = 70
    var episodeViewModel: EpisodeViewModel! {
        didSet {
            imageView.sd_setImage(with: episodeViewModel.imageUrl)
            titleLabel.text = episodeViewModel.title
        }
    }
    weak var delegate: EpisodeMiniPlayerViewDelegate?
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"), contentMode: .scaleToFill)
    let titleLabel = MarqueeLabel(text: nil, font: .systemFont(ofSize: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
    let playerControlButton = UIButton(image: #imageLiteral(resourceName: "play"), tintColor: .black, target: self, action: #selector(handlePlayerPauseAndPlay))
    let nextTrackButton = UIButton(image: #imageLiteral(resourceName: "next"), tintColor: .black, target: self, action: #selector(handleNextTrack))
    lazy var btnHStackView = UIStackView(subViews: [
                                              playerControlButton,
                                              nextTrackButton],
                                   axis: .horizontal,
                                   alignment: .center,
                                   distribution: .fillEqually,
                                   spacing: 0)
    lazy var hStackView = UIStackView(subViews: [imageView,
                                                 titleLabel,
                                                 btnHStackView],
                                      axis: .horizontal,
                                      alignment: .center,
                                      spacing: 7)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        layer.shadowOpacity = 0.1
        nextTrackButton.imageView?.contentMode = .scaleAspectFit
        setupMarqueeLabel()
        setupConstraints()
        addGesture()
    }
    fileprivate func addGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMiniPlayerTapped))
        addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMiniPlayerViewPanned(gesture:)))
        addGestureRecognizer(panGesture)
    }
    fileprivate func setupMarqueeLabel(){
        titleLabel.type = .continuous
        titleLabel.speed = .rate(20) //points per second
        titleLabel.animationCurve = .linear
        titleLabel.fadeLength = 10.0
        titleLabel.trailingBuffer = 30.0
    }
    fileprivate func setupConstraints(){
        addSubview(hStackView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        hStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: frame.width * 0.0169, left: frame.width * 0.0362, bottom: frame.width * 0.0169, right: frame.width * 0.0362))
        //固定Label,避免title文字太少,造成label寬度自動減少,stackView的subViews排版會受影響
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .zero, size: .init(width: frame.width * 0.55, height: 0))
        imageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .zero, size: .init(width: frame.width * 0.1087, height: frame.width * 0.1087))
        btnHStackView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .zero, size: .init(width: 0, height: frame.width * 0.06))
        
        //Aspect Fit：等比例縮放圖片直到完整顯示在Image View中，有時會出現Image View留白的部分
        //讓btn寬度增加的同時,imageView不會跟著被延伸
        nextTrackButton.imageView?.contentMode = .scaleAspectFit
        playerControlButton.imageView?.contentMode = .scaleAspectFit
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
    @objc fileprivate func handleNextTrack(){
        delegate?.playNextTrack()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
