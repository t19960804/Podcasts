//
//  EpisodePlayerController.swift
//  Podcasts
//
//  Created by t19960804 on 5/1/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import AVKit

class EpisodePlayerController: UIViewController {
    var episode: Episode! {
        didSet {
            let imageUrlString = episode.imageURL
            let imageUrl = URL(string: imageUrlString ?? "")
            episodeImageView.sd_setImage(with: imageUrl)
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            let audioUtlString = episode.audioURL
            if let audioUrl = URL(string: audioUtlString ?? "") {
                playAudio(with: audioUrl)
            }
        }
    }
    lazy var dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Dismiss", for: .normal)
        btn.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    let episodeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        return iv
    }()
    //MARK: - StackView_Time
    let timeSlider: UISlider = {
        let sd = UISlider()
        return sd
    }()
    let timeLabel_LowerBound: UILabel = {
        let lb = UILabel()
        lb.text = "00:00:00"
        lb.textColor = .darkGray
        return lb
    }()
    let timeLabel_UpperBound: UILabel = {
        let lb = UILabel()
        lb.text = "99:99:99"
        lb.textColor = .darkGray
        return lb
    }()
    lazy var hStackView_Time: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [timeLabel_LowerBound,
                                                UIView(),
                                                timeLabel_UpperBound])
        sv.axis = .horizontal
        return sv
    }()
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Title"
        lb.textAlignment = .center
        lb.numberOfLines = 2
        lb.font = .boldSystemFont(ofSize: 18)
        return lb
    }()
    let authorLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Author Name"
        lb.textAlignment = .center
        lb.font = .boldSystemFont(ofSize: 18)
        lb.textColor = .purple
        return lb
    }()
    //MARK: - StackView_OperationBtn
    let rewindButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "rewind15"), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    lazy var playButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handlePlayAndPause), for: .touchUpInside)
        return btn
    }()
    let fastForwardButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "fastforward15"), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    lazy var hStackView_OperationButton: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [rewindButton,
                                                playButton,
                                                fastForwardButton])
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()
    //MARK: - StackView_Sound
    let soundLowerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "muted_volume")
        return iv
    }()
    let soundSlider: UISlider = {
        let sd = UISlider()
        return sd
    }()
    let soundLouderImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "max_volume")
        return iv
    }()
    lazy var hStackView_Sound: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [soundLowerImageView,
                                                soundSlider,
                                                soundLouderImageView])
        sv.axis = .horizontal
        return sv
    }()
    //MARK: - StackView_Whole
    lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [dismissButton,
                                                episodeImageView,
                                                timeSlider,
                                                hStackView_Time,
                                                titleLabel,
                                                authorLabel,
                                                hStackView_OperationButton,
                                                hStackView_Sound,
                                                UIView()])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    let avPlayer: AVPlayer = {
        let player = AVPlayer()
        //設為true時player會延遲載入,讓緩衝區可以裝下更多資料,初始播放速度慢,但播放過程中比較不會Lag
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpConstraints()
    }
    func setUpConstraints(){
        view.addSubview(vStackView)
        vStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        vStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        vStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        vStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        
        dismissButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        episodeImageView.heightAnchor.constraint(equalTo: episodeImageView.widthAnchor, multiplier: 1).isActive = true
        timeSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        hStackView_Time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        authorLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        hStackView_OperationButton.heightAnchor.constraint(equalToConstant: 170).isActive = true
        hStackView_Sound.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    func playAudio(with url: URL) {
        let item = AVPlayerItem(url: url)
        avPlayer.replaceCurrentItem(with: item)
        playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        avPlayer.play()
    }
    @objc fileprivate func handleDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc fileprivate func handlePlayAndPause(){
        if avPlayer.timeControlStatus == .playing {
            avPlayer.pause()
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            avPlayer.play()
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
    }
}
