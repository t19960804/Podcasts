//
//  EpisodePlayerView.swift
//  Podcasts
//
//  Created by t19960804 on 6/26/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import AVKit

class EpisodePlayerView: UIView {
    var episode: Episode? {
        didSet {
            guard let episode = episode else { return }//mini > fullScrren不需要重新播放
            let imageUrlString = episode.imageURL
            let imageUrl = URL(string: imageUrlString ?? "")
            episodeImageView.sd_setImage(with: imageUrl)
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            miniPlayerView.episode = episode
            let audioUtlString = episode.audioURL
            if let audioUrl = URL(string: audioUtlString ?? "") {
                playAudio(with: audioUrl)
            }
        }
    }
    lazy var dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Dismiss", for: .normal)
        btn.addTarget(self, action: #selector(handleDismissPlayerView), for: .touchUpInside)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    let episodeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        iv.layer.cornerRadius = 5
        iv.clipsToBounds = true
        return iv
    }()
    //MARK: - StackView_Time
    let timeSlider: UISlider = {
        let sd = UISlider()
        sd.addTarget(self, action: #selector(handleTimeSliderValueChanged(slider:)), for: .valueChanged)
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
        lb.text = "--:--:--"
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
        btn.addTarget(self, action: #selector(handleRewindAndForward(button:)), for: .touchUpInside)
        return btn
    }()
    lazy var playerControlButton: UIButton = {
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
        btn.addTarget(self, action: #selector(handleRewindAndForward(button:)), for: .touchUpInside)
        return btn
    }()
    lazy var hStackView_OperationButton: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [rewindButton,
                                                playerControlButton,
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
        sd.addTarget(self, action: #selector(handleSoundSliderValueChanged(slider:)), for: .valueChanged)
        sd.value = 1 //因為podcastPlayer.volume預設值為1
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
    let podcastPlayer: AVPlayer = {
        let player = AVPlayer()
        //設為true時player會延遲載入,讓緩衝區可以裝下更多資料,初始播放速度慢,但播放過程中比較不會Lag
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    let miniPlayerView = EpisodeMiniPlayerView()
    var panGesture: UIPanGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        setUpConstraints()
        scaleDownEpisodeImageView()
        updateUIWhenPoadcastStartPlaying()
        updateCurrentPlayingTimePeriodically()
        miniPlayerView.delegate = self
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer){
        if gesture.state == .began {
            
        } else if gesture.state == .changed {
            handlePanChanged(gesture: gesture)
        } else {
            handlePanEnded(gesture: gesture)
        }
    }
    func handlePanChanged(gesture: UIPanGestureRecognizer){
        //手勢位移量,上負下正
        let translation = gesture.translation(in: self.superview)
        transform = CGAffineTransform(translationX: 0, y: translation.y)
        //Hide miniPlayer
        miniPlayerView.alpha = 1 + translation.y / 200
        //Show fullScreenPlayer
        vStackView.alpha = -translation.y / 300
    }
    func handlePanEnded(gesture: UIPanGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            let location = gesture.location(in: self.superview)
            let velocity = gesture.velocity(in: self.superview)//點擊拖曳到放下點擊的速度
            if location.y < 300 || velocity.y < -500{
                let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                tabbarController?.maximizePodcastPlayerView(episode: nil)
                gesture.isEnabled = false
            } else {
                //Minimize
                self.miniPlayerView.alpha = 1
                self.vStackView.alpha = 0
                gesture.isEnabled = true
            }
            
        })
    }
    func setUpConstraints(){
        miniPlayerView.isHidden = true
        addSubview(vStackView)
        addSubview(miniPlayerView)
        miniPlayerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        miniPlayerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        miniPlayerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        miniPlayerView.heightAnchor.constraint(equalToConstant: EpisodeMiniPlayerView.height).isActive = true
        
        vStackView.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        vStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        vStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        vStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
        
        dismissButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        episodeImageView.heightAnchor.constraint(equalTo: episodeImageView.widthAnchor, multiplier: 1).isActive = true
        timeSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        hStackView_Time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        authorLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        hStackView_OperationButton.heightAnchor.constraint(equalToConstant: 170).isActive = true
        hStackView_Sound.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    fileprivate func updateUIWhenPoadcastStartPlaying(){
           //value: 當前為第幾個Frame, timeScale: 一秒播放多少個frame,下例為0.33秒
           //https://blog.csdn.net/caiwenyu9999/article/details/51518960
           let time = CMTime(value: 1, timescale: 3)
           let times = [NSValue(time: time)]
           //在播放期間,若跨過指定的時間,就執行closure
           podcastPlayer.addBoundaryTimeObserver(forTimes: times, queue: .main) {
               [weak self] in //避免Retain Cycle
               self?.scaleUpEpisodeImageView()
               let duration = self?.podcastPlayer.currentItem?.asset.duration
               self?.timeLabel_UpperBound.text = duration?.getFormattedString()
           }
       }
    fileprivate func updateCurrentPlayingTimePeriodically(){
        let interval = CMTime(value: 1, timescale: 2) //0.5秒執行一次call back來更新進度
        podcastPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (currentTime) in //避免Retain Cycle
            self?.timeLabel_LowerBound.text = currentTime.getFormattedString()
            self?.updateTimeSlider()
        }
    }
    fileprivate func updateTimeSlider(){
        let currentSeconds = CMTimeGetSeconds(podcastPlayer.currentTime())
        let duration = podcastPlayer.currentItem?.asset.duration
        let totalSeconds = CMTimeGetSeconds(duration ?? CMTime(value: 1, timescale: 1))
        let progressPercent = currentSeconds / totalSeconds
        timeSlider.value = Float(progressPercent)
    }
    func playAudio(with url: URL) {
        let item = AVPlayerItem(url: url)
        podcastPlayer.replaceCurrentItem(with: item)
        playPodcats()
    }
    @objc fileprivate func handleTimeSliderValueChanged(slider: UISlider){
        guard let duration = podcastPlayer.currentItem?.duration else {
            print("Error - currentItem is nil")
            return
        }
        let durationInSeconds = CMTimeGetSeconds(duration)
         //總秒數乘以Slider的值(0 - 1),做為要快 / 倒轉的秒數
        let seekTimeInSeconds = Float64(slider.value) * durationInSeconds
        let seekTime = CMTime(seconds: seekTimeInSeconds, preferredTimescale: 1)
        podcastPlayer.seek(to: seekTime)
    }
    @objc fileprivate func handleRewindAndForward(button: UIButton){
        let currentTime = podcastPlayer.currentTime()
        let deltaSeconds: Int64 = button == rewindButton ? -15 : 15
        let deltaTime = CMTime(value: deltaSeconds, timescale: 1)
        let seekTime = CMTimeAdd(currentTime, deltaTime)//也可以像上面的method,將currentTime轉秒數在做加減
        podcastPlayer.seek(to: seekTime)
    }
    @objc fileprivate func handleSoundSliderValueChanged(slider: UISlider){
        podcastPlayer.volume = slider.value
    }
    @objc fileprivate func handleDismissPlayerView(){
        let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        tabBarController?.minimizePodcastPlayerView()
        panGesture.isEnabled = true
    }
    @objc fileprivate func handlePlayAndPause(){
        if podcastPlayer.timeControlStatus == .playing {
            scaleDownEpisodeImageView()
            pausePodcats()
        } else {
            scaleUpEpisodeImageView()
            playPodcats()
        }
    }
    fileprivate func playPodcats(){
        podcastPlayer.play()
        playerControlButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayerView.playerControlButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    fileprivate func pausePodcats(){
        podcastPlayer.pause()
        playerControlButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        miniPlayerView.playerControlButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    //MARK: - Image Scale up / down
    fileprivate func scaleDownEpisodeImageView(completion: ((Bool) -> Void)? = nil){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: completion)
    }
    fileprivate func scaleUpEpisodeImageView(completion: ((Bool) -> Void)? = nil){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
                self.episodeImageView.transform = CGAffineTransform.identity
        }, completion: completion)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EpisodePlayerView: EpisodeMiniPlayerViewDelegate {
    func handleMiniPlayerTapped() {
        let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        tabBarController?.maximizePodcastPlayerView(episode: nil)
        panGesture.isEnabled = false
    }
    
    func handlePlayerControl() {
        handlePlayAndPause()
    }
    
    func cancelMiniPlayerView() {
        scaleDownEpisodeImageView()
        pausePodcats()
        miniPlayerView.isHidden = true
    }
}
