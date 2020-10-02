//
//  EpisodePlayerView.swift
//  Podcasts
//
//  Created by t19960804 on 6/26/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class EpisodePlayerView: UIView {
    var episodesList = [EpisodeViewModel]()
    var episodeViewModel: EpisodeViewModel? {
        didSet {
            guard let episodeViewModel = episodeViewModel else { return }//mini > fullScrren不需要重新播放
            episodeImageView.sd_setImage(with: episodeViewModel.imageUrl) { (image, _, _, _) in
                MPNowPlayingInfoCenter.default().setInfo(title: episodeViewModel.title, artist: episodeViewModel.author, image: image)
            }
            titleLabel.text = episodeViewModel.title
            authorLabel.text = episodeViewModel.author
            miniPlayerView.episodeViewModel = episodeViewModel
            setupAudioSession()//播放時再取得Audio使用權
            playAudio(with: episodeViewModel.audioUrl)
        }
    }
    let dismissButton = UIButton(title: "Dismiss", titleColor: .black, font: .boldSystemFont(ofSize: 16), target: self, action: #selector(handleDismissPlayerView))
    let episodeImageView = UIImageView(image: #imageLiteral(resourceName: "appicon"), cornerRadius: 5, clipsToBounds: true)
    //MARK: - StackView_Time
    let timeSlider: UISlider = {
        let sd = UISlider()
        sd.addTarget(self, action: #selector(handleTimeSliderValueChanged(slider:event:)), for: .valueChanged)
        return sd
    }()
    let timeLabel_LowerBound = UILabel(text: "00:00:00", textColor: .darkGray)
    let timeLabel_UpperBound = UILabel(text: "--:--:--", textColor: .darkGray)
    lazy var hStackView_Time = UIStackView(subViews: [timeLabel_LowerBound,
                                                      UIView(),
                                                      timeLabel_UpperBound],
                                           axis: .horizontal)
    let titleLabel = UILabel(text: "Title", font: .boldSystemFont(ofSize: 18), textAlignment: .center, numberOfLines: 2)
    let authorLabel = UILabel(text: "Author Name", font: .boldSystemFont(ofSize: 18), textColor: .purple, textAlignment: .center)
    //MARK: - StackView_OperationBtn
    let rewindButton = UIButton(image: #imageLiteral(resourceName: "rewind15"), tintColor: .black, target: self, action: #selector(handleRewindAndForward(button:)))
    let playerControlButton = UIButton(image: #imageLiteral(resourceName: "play"), tintColor: .black, target: self, action: #selector(handlePlayAndPause))
    let fastForwardButton = UIButton(image: #imageLiteral(resourceName: "fastforward15"), tintColor: .black, target: self, action: #selector(handleRewindAndForward(button:)))
    lazy var hStackView_OperationButton = UIStackView(subViews: [rewindButton,
                                                                 playerControlButton,
                                                                 fastForwardButton],
                                                      axis: .horizontal,
                                                      distribution: .fillEqually)
    //MARK: - StackView_Sound
    let soundLowerImageView = UIImageView(image: #imageLiteral(resourceName: "muted_volume"))
    let soundLouderImageView = UIImageView(image: #imageLiteral(resourceName: "max_volume"))
    let soundSlider: UISlider = {
        let sd = UISlider()
        sd.addTarget(self, action: #selector(handleSoundSliderValueChanged(slider:)), for: .valueChanged)
        sd.value = 1 //因為podcastPlayer.volume預設值為1
        return sd
    }()
    lazy var hStackView_Sound = UIStackView(subViews: [soundLowerImageView,
                                                       soundSlider,
                                                       soundLouderImageView],
                                            axis: .horizontal)
    //MARK: - StackView_Whole
    lazy var vStackView = UIStackView(subViews: [dismissButton,
                                                 episodeImageView,
                                                 timeSlider,
                                                 hStackView_Time,
                                                 titleLabel,
                                                 authorLabel,
                                                 hStackView_OperationButton,
                                                 hStackView_Sound,
                                                 UIView()],
                                      axis: .vertical,
                                      spacing: 8)
    let podcastPlayer: AVPlayer = {
        let player = AVPlayer()
        //設為true時player會延遲載入,讓緩衝區可以裝下更多資料,初始播放速度慢,但播放過程中比較不會Lag
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    let miniPlayerView = EpisodeMiniPlayerView()
    var isSeekingTime = false //防止拖動slider時,slider被update到currentTime
    let commandCenter = MPRemoteCommandCenter.shared()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        setUpConstraints()
        scaleDownEpisodeImageView()
        updateUIWhenPoadcastStartPlaying()
        updateCurrentPlayingTimePeriodically()
        miniPlayerView.delegate = self
        setupGesture()
        setupRemoteControl()
        setupInterruptionNotification()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - Interruption handle
    fileprivate func setupInterruptionNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    @objc fileprivate func handleInterruption(notification: Notification){
        let userInfo = notification.userInfo
        guard let interruptionType = userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else {
            return
        }
        if interruptionType == AVAudioSession.InterruptionType.began.rawValue {
            scaleDownEpisodeImageView()
            //不用.pause,被干擾時player會自動pause
            playerControlButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerView.playerControlButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    //MARK: - Command Center
    fileprivate func setupRemoteControl(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.updateLockScreenElapsedTime()
            self.handlePlayAndPause()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.updateLockScreenElapsedTime()
            self.handlePlayAndPause()
            return .success
        }
        //耳機上的暫停 / 播放鈕
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayAndPause()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
    }
    @objc fileprivate func handleNextTrack() -> MPRemoteCommandHandlerStatus {
        if episodesList.isEmpty {
            print("Error - Can not get next episode because list is empty")
            return .commandFailed
        }
        let currentEpisodeIndex = episodesList.firstIndex { $0.title == episodeViewModel?.title }
        guard let index = currentEpisodeIndex else {
            print("Error - Can not get episode index from list")
            return .commandFailed
        }
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        
        let needTurnBackToFirstEpisode = index == episodesList.count - 1
        let episode = needTurnBackToFirstEpisode ? episodesList.first : episodesList[index + 1]
        episodeViewModel = episode
        return .success
    }
    @objc fileprivate func handlePreviousTrack() -> MPRemoteCommandHandlerStatus {
        if episodesList.isEmpty {
            print("Error - Can not get previous episode because list is empty")
            return .commandFailed
        }
        let currentEpisodeIndex = episodesList.firstIndex { $0.title == episodeViewModel?.title }
        guard let index = currentEpisodeIndex else {
            print("Error - Can not get episode index from list")
            return .commandFailed
        }
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        
        let needTurnBackToLastEpisode = index == 0
        let episode = needTurnBackToLastEpisode ? episodesList.last : episodesList[index - 1]
        episodeViewModel = episode
        return .success
    }
    //MARK: - Lock Screen Player
    fileprivate func updateLockScreenElapsedTime(){
        MPNowPlayingInfoCenter.default().setElapsedTime(with: podcastPlayer.currentTime())
    }
    fileprivate func updateLockScreenDuration(){
        let duration = podcastPlayer.currentItem?.asset.duration
        MPNowPlayingInfoCenter.default().setDuration(with: duration)
    }
    //若沒有加入此Function,有時背景播放會無效
    fileprivate func setupAudioSession(){
        do {
            //https://ithelp.ithome.com.tw/articles/10195770?sc=iThelpR
            //App - AVAudioSession(中介) - OS
            //使用AVAudioSession來告訴OS我們要在App中要如何使用Audio
            try AVAudioSession.sharedInstance().setCategory(.playback)
            //向OS請求使用Audio,因為多個App中只能有一個使用Audio,比如一通電話打來,電話就有使用Audio的最高優先,低優先的會被暫停
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError{
            //https://stackoverflow.com/questions/31352593/how-to-print-details-of-a-catch-all-exception-in-swift
            print("Set up session failed:\(sessionError)")
        }
    }
    //MARk: - Gesture
    func setupGesture(){
        let panGrsture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(panGrsture)
    }
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: superview)
        
        if gesture.state == .began {
            
        } else if gesture.state == .changed {
            transform = CGAffineTransform(translationX: 0, y: max(0,translation.y))
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                //因為中間經過了transform,若不先用identity回到原位,會導致anchor更新後元件位置有誤
                self.transform = .identity
                
                if translation.y > 100 {
                    let tabBarController = UIApplication.mainTabBarController
                    tabBarController?.minimizePodcastPlayerView()
                }
            })
        }
    }
    //MARK: - Constraints
    func setUpConstraints(){
        miniPlayerView.isHidden = true
        addSubview(vStackView)
        addSubview(miniPlayerView)
        miniPlayerView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, size: .init(width: 0, height: EpisodeMiniPlayerView.height))
        
        vStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 40, left: 24, bottom: 24, right: 24))
        
        dismissButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.033).isActive = true
        timeSlider.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.041).isActive = true
        hStackView_Time.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.027).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.06).isActive = true
        authorLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.027).isActive = true
        hStackView_OperationButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.19).isActive = true

        hStackView_Sound.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.041).isActive = true
    }
    fileprivate func updateUIWhenPoadcastStartPlaying(){
           //value: 當前為第幾個Frame, timeScale: 一秒播放多少個frame,下例為0.33秒
           //https://blog.csdn.net/caiwenyu9999/article/details/51518960
           let time = CMTime(value: 1, timescale: 3)
           let times = [NSValue(time: time)]
           //在播放期間,若跨過指定的時間,就執行closure
           podcastPlayer.addBoundaryTimeObserver(forTimes: times, queue: .main) {
               [weak self] in
                guard let self = self else { return }
                self.scaleUpEpisodeImageView()
                let duration = self.podcastPlayer.currentItem?.asset.duration
                self.timeLabel_UpperBound.text = duration?.getFormattedString()
                self.updateLockScreenDuration()
                self.commandCenter.nextTrackCommand.isEnabled = true
                self.commandCenter.previousTrackCommand.isEnabled = true
           }
       }
    fileprivate func updateCurrentPlayingTimePeriodically(){
        let interval = CMTime(value: 1, timescale: 2) //0.5秒執行一次call back來更新進度
        podcastPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (currentTime) in
            guard let self = self else { return }
            if self.isSeekingTime == false {
                self.timeLabel_LowerBound.text = currentTime.getFormattedString()
                self.updateTimeSlider()
                //LockScreen的ElapsedTime跟Player的會有落差,所以要同步更新
                self.updateLockScreenElapsedTime()
            }
        }
    }
    fileprivate func updateTimeSlider(){
        let currentSeconds = podcastPlayer.currentTime().toSeconds()
        guard let duration = podcastPlayer.currentItem?.asset.duration else { return }
        let totalSeconds = duration.toSeconds()
        let progressPercent = currentSeconds / totalSeconds
        timeSlider.value = Float(progressPercent)
    }
    fileprivate func playAudio(with url: URL?) {
        guard let url = url else { return }
        let item = AVPlayerItem(url: url)
        podcastPlayer.replaceCurrentItem(with: item)
        playPodcats()
    }
    @objc fileprivate func handleTimeSliderValueChanged(slider: UISlider, event: UIEvent){
        guard let duration = podcastPlayer.currentItem?.duration else {
            print("Error - currentItem is nil")
            return
        }
        let durationInSeconds = duration.toSeconds()
        //總秒數乘以Slider的值(0 - 1),做為要快 / 倒轉的秒數
        let seekTimeInSeconds = Float64(slider.value) * durationInSeconds
        //一秒切成1000份(1份 = 0.001秒),假設我們想要123.45秒,由於0.45秒(450份)可以提供,故為238.87秒
        //若preferredTimescale為1,將無法處理小數點的情況,因為小數點不滿一份(1秒)
        let seekTime = CMTime(seconds: seekTimeInSeconds, preferredTimescale: 1000)
        timeLabel_LowerBound.text = seekTime.getFormattedString()

        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                print("tlee slider began")
            case .moved:
                print("tlee slider moved")
                isSeekingTime = true
            case .ended:
                print("tlee slider ended")
                //過多的seekRequest會導致seek出問題,只需要在ended做
                //https://developer.apple.com/documentation/avfoundation/avplayer/1387018-seek
                podcastPlayer.seek(to: seekTime) { (isFinished) in
                    if isFinished {
                        self.isSeekingTime = false
                    }
                }
            default:
                break
            }
        }
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
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.minimizePodcastPlayerView()
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
    func handleMiniPlayerViewPanned(gesture: UIPanGestureRecognizer) {
      if gesture.state == .began {
            
        } else if gesture.state == .changed {
            handlePanChanged(gesture: gesture)
        } else {
            handlePanEnded(gesture: gesture)
        }
    }
    func handlePanChanged(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: superview)//與手勢原點的位移量,有正有負
        transform = CGAffineTransform(translationX: 0, y: translation.y)
        //Hide miniPlayer
        miniPlayerView.alpha = 1 + translation.y / 200
        //Show fullScreenPlayer
        vStackView.alpha = -translation.y / 300
    }
    func handlePanEnded(gesture: UIPanGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //因為中間經過了transform,若不先用identity回到原位,會導致anchor更新後元件位置有誤
            self.transform = .identity
            let translation = gesture.translation(in: self.superview)
            let velocity = gesture.velocity(in: self.superview)//點擊拖曳到放下點擊的速度
            
            if translation.y < -200 || velocity.y < -500{
                let tabbarController = UIApplication.mainTabBarController
                tabbarController?.maximizePodcastPlayerView(episodeViewModel: nil, episodesList: self.episodesList)
            } else {
                //Minimize
                self.miniPlayerView.alpha = 1
                self.vStackView.alpha = 0
            }
            
        })
    }
    func handleMiniPlayerTapped() {
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.maximizePodcastPlayerView(episodeViewModel: nil, episodesList: self.episodesList)
    }
    
    func handlePlayerPauseAndPlay() {
        handlePlayAndPause()
    }
    
    func cancelMiniPlayerView() {
        scaleDownEpisodeImageView()
        pausePodcats()
        
        guard let mainTabBarController = UIApplication.mainTabBarController else { return }
        mainTabBarController.topAnchorForMiniPlayer?.isActive = false
        mainTabBarController.topAnchorForFullScreenPlayer?.constant = mainTabBarController.view.frame.height
        mainTabBarController.topAnchorForFullScreenPlayer?.isActive = true
        
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        })
    }
}
