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
import MarqueeLabel
import Combine

class EpisodePlayerView: UIView {

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
    let titleLabel = MarqueeLabel(text: "Title", font: .boldSystemFont(ofSize: 18), textAlignment: .center, numberOfLines: 1)
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
    let commandCenter = MPRemoteCommandCenter.shared()

    let viewModel = EpisodePlayerViewModel()
    private var sliderValueSubscriber: AnyCancellable?
    private var volumeSubscriber: AnyCancellable?
    private var seekTimeSubscriber: AnyCancellable?
    private var startToPlayEpisodeSubscriber: AnyCancellable?
    private var needToPausePlayerSubscriber: AnyCancellable?
    private var currentEpisodeSubscriber: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        setupMarqueeLabel()
        updateUIWhenPoadcastStartPlaying()
        updateCurrentPlayingTimePeriodically()
        miniPlayerView.delegate = self
        setupGesture()
        setupRemoteControl()
        setupInterruptionNotification()
        podcastPlayer.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        
        currentEpisodeSubscriber = viewModel.$currentEpisode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] episode in
                guard let self = self else { return }
                guard let episode = episode else { return }
                self.episodeImageView.sd_setImage(with: episode.imageUrl) { (image, _, _, _) in
                    MPNowPlayingInfoCenter.default().setInfo(title: episode.title, artist: episode.author, image: image)
                }
                self.titleLabel.text = episode.title
                self.authorLabel.text = episode.author
                self.timeLabel_UpperBound.text = episode.duration
                self.miniPlayerView.episodeViewModel = episode
                if let downloadEpisode = episode as? DownloadProtocol {
                    self.playAudio(with: downloadEpisode.fileUrl?.getTrueLocation())
                } else {
                    self.playAudio(with: episode.audioUrl)
                }
            }
        needToPausePlayerSubscriber = viewModel.$needToPausePlayer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] needToPause in
                guard let self = self else { return }
                if needToPause {
                    self.podcastPlayer.pause()
                } else {
                    self.podcastPlayer.play()
                }
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
                    let transForm: CGAffineTransform = needToPause ? .init(scaleX: 0.8, y: 0.8) : .identity
                        self.episodeImageView.transform = transForm
                })
                let image = needToPause ? #imageLiteral(resourceName: "play") : #imageLiteral(resourceName: "pause")
                self.playerControlButton.setImage(image, for: .normal)
                self.miniPlayerView.playerControlButton.setImage(image, for: .normal)
            }
        sliderValueSubscriber = viewModel.$sliderValue
            .map{Float($0)}
            .receive(on: DispatchQueue.main)
            .assign(to: \.value, on: timeSlider)
        
        volumeSubscriber = viewModel.$volume
            .receive(on: DispatchQueue.main)
            .assign(to: \.volume, on: podcastPlayer)
        viewModel.volume = 1
        
        seekTimeSubscriber = viewModel.$seekTime
            .map{$0.getFormattedString()}
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: timeLabel_LowerBound)
        
        startToPlayEpisodeSubscriber = viewModel.$startToPlayEpisode
            .sink { [weak self](startToPlay) in
                guard let self = self else { return }
                self.commandCenter.nextTrackCommand.isEnabled = startToPlay
                self.commandCenter.previousTrackCommand.isEnabled = startToPlay
            }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        sliderValueSubscriber?.cancel()
        volumeSubscriber?.cancel()
        seekTimeSubscriber?.cancel()
        startToPlayEpisodeSubscriber?.cancel()
        needToPausePlayerSubscriber?.cancel()
        currentEpisodeSubscriber?.cancel()
    }
    //Detect if player was paused or not
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let info: [String : Any?] = [ Notification.episodeKey : viewModel.currentEpisode,
                                      Notification.previousEpisodeKey : viewModel.previousEpisode]
        if keyPath == "rate" {
            NotificationCenter.default.post(name: .playerStateUpdate, object: nil, userInfo: info as [AnyHashable : Any])
        }
    }
    fileprivate func setupMarqueeLabel(){
        titleLabel.type = .continuous
        titleLabel.speed = .rate(20) //points per second
        titleLabel.animationCurve = .linear
        titleLabel.fadeLength = 10.0
        titleLabel.trailingBuffer = 30.0
    }
    //MARK: - Interruption handle
    fileprivate func setupInterruptionNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    @objc fileprivate func handleInterruption(notification: Notification){
        viewModel.handleInteruption(notification: notification)
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
        let result = viewModel.playNextEpisode(currentEpisode: viewModel.currentEpisode)
        return result ? .success : .commandFailed
    }
    @objc fileprivate func handlePreviousTrack() -> MPRemoteCommandHandlerStatus {
        let result = viewModel.playPreviousEpisode(currentEpisode: viewModel.currentEpisode)
        return result ? .success : .commandFailed
    }
    //MARK: - Lock Screen Player
    fileprivate func updateLockScreenElapsedTime(){
        MPNowPlayingInfoCenter.default().setElapsedTime(with: podcastPlayer.currentTime())
    }
    fileprivate func updateLockScreenDuration(){
        let duration = podcastPlayer.currentItem?.asset.duration
        MPNowPlayingInfoCenter.default().setDuration(with: duration)
    }
    //MARk: - Gesture
    func setupGesture(){
        let panGrsture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(panGrsture)
    }
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: superview)
        let tabBarController = UIApplication.mainTabBarController

        if gesture.state == .began {
            
        } else if gesture.state == .changed {
            transform = CGAffineTransform(translationX: 0, y: max(0,translation.y))
            tabBarController?.tabBar.isHidden = true
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                //因為中間經過了transform,若不先用identity回到原位,會導致anchor更新後元件位置有誤
                self.transform = .identity
                if translation.y > 100 {
                    tabBarController?.tabBar.isHidden = false
                    tabBarController?.minimizePodcastPlayerView()
                } else {
                    tabBarController?.tabBar.isHidden = true
                }
            })
        }
    }
    //MARK: - Constraints
    func setUpUI(){
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        rewindButton.tag = 1
        fastForwardButton.tag = 2
        miniPlayerView.isHidden = true
        addSubview(vStackView)
        addSubview(miniPlayerView)
        
        //Constraints
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
    //MARK: - Player action
    fileprivate func updateUIWhenPoadcastStartPlaying(){
       //value: 當前為第幾個Frame, timeScale: 一秒播放多少個frame,下例為0.33秒
       //https://blog.csdn.net/caiwenyu9999/article/details/51518960
       let time = CMTime(value: 1, timescale: 3)
       let times = [NSValue(time: time)]
       //在播放期間,若跨過指定的時間,就執行closure
       podcastPlayer.addBoundaryTimeObserver(forTimes: times, queue: .main) {
           [weak self] in
            self?.updateLockScreenDuration()
            self?.viewModel.startToPlayEpisode = true
       }
    }
    fileprivate func updateCurrentPlayingTimePeriodically(){
        let interval = CMTime(value: 1, timescale: 2) //0.5秒執行一次call back來更新進度
        podcastPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (currentTime) in
            guard let self = self else { return }
            if self.viewModel.isSeekingTime == false {
                self.viewModel.seekTime = currentTime
                guard let duration = self.podcastPlayer.currentItem?.asset.duration else { return }
                self.viewModel.updateTimeSliderValue(currentTime: self.podcastPlayer.currentTime(), duration: duration)
                //LockScreen的ElapsedTime跟Player的會有落差,所以要同步更新
                self.updateLockScreenElapsedTime()
            }
        }
    }
    fileprivate func playAudio(with url: URL?) {
        guard let url = url else {
            print("Error - audio url is nil")
            return
        }
        let item = AVPlayerItem(url: url)
        podcastPlayer.replaceCurrentItem(with: item)
        viewModel.needToPausePlayer = false
    }
    @objc fileprivate func handleTimeSliderValueChanged(slider: UISlider, event: UIEvent){
        guard let duration = podcastPlayer.currentItem?.duration else {
            print("Error - currentItem is nil")
            return
        }
        viewModel.calculateSeekTime_TimeSilderDragged(ratio: slider.value, duration: duration)
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                print("tlee slider began")
            case .moved:
                print("tlee slider moved")
                viewModel.isSeekingTime = true
            case .ended:
                print("tlee slider ended")
                //過多的seekRequest會導致seek出問題,只需要在ended做
                //https://developer.apple.com/documentation/avfoundation/avplayer/1387018-seek
                podcastPlayer.seek(to: viewModel.seekTime) { [weak self](isFinished) in
                    if isFinished {
                        self?.viewModel.isSeekingTime = false
                    }
                }
            default:
                break
            }
        }
    }
    @objc fileprivate func handleRewindAndForward(button: UIButton){
        let currentTime = podcastPlayer.currentTime()
        viewModel.calculateSeekTime_RewindAndFastforward(currentTime: currentTime, tag: button.tag)
        podcastPlayer.seek(to: viewModel.seekTime)
    }
    @objc fileprivate func handleSoundSliderValueChanged(slider: UISlider){
        viewModel.volume = slider.value
    }
    @objc fileprivate func handleDismissPlayerView(){
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.minimizePodcastPlayerView()
    }
    @objc fileprivate func handlePlayAndPause(){
        viewModel.needToPausePlayer = podcastPlayer.isPlayingItem
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EpisodePlayerView: EpisodeMiniPlayerViewDelegate {
    func handleMiniPlayerViewPanned(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            break
        case .changed:
            handlePanChanged(gesture: gesture)
        default:
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
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [self] in
            //因為中間經過了transform,若不先用identity回到原位,會導致anchor更新後元件位置有誤
            self.transform = .identity
            let translation = gesture.translation(in: self.superview)
            let velocity = gesture.velocity(in: self.superview)//點擊拖曳到放下點擊的速度
            
            if translation.y < -200 || velocity.y < -500{
                let tabbarController = UIApplication.mainTabBarController
                tabbarController?.maximizePodcastPlayerView(episodeViewModel: nil, episodesList: viewModel.episodesList)
            } else {
                //Minimize
                self.miniPlayerView.alpha = 1
                self.vStackView.alpha = 0
            }
            
        })
    }
    func handleMiniPlayerTapped() {
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.maximizePodcastPlayerView(episodeViewModel: nil, episodesList: viewModel.episodesList)
    }
    
    func handlePlayerPauseAndPlay() {
        handlePlayAndPause()
    }
    
    func playNextTrack() {
        let _ = self.handleNextTrack()
    }
}
