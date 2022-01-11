//
//  AVPlayerSampleViewController.swift
//  AVPlayerSample
//
//  Created by 渡辺幹人 on 2019/05/03.
//  Copyright © 2019 渡辺幹人. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class AVPlayerSampleViewController: UIViewController {

    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var pipStartButton: UIButton!
    @IBOutlet weak var pipStopButton: UIButton!
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }
    
    var hlsUrl: String?
    var vttUrl: String?

    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pipStartImage = AVPictureInPictureController.pictureInPictureButtonStartImage(compatibleWith: nil)
        let pipStopImage = AVPictureInPictureController.pictureInPictureButtonStopImage(compatibleWith: nil)
        pipStartButton.setImage(pipStartImage, for: .normal)
        pipStopButton.setImage(pipStopImage, for: .normal)
        
        setupPlayer()
        //setupPlayerWithComposition()
        setupAirPlay()
        
        addRemoteCommand()
        addNowPlayingInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(connectPlayer(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPlayer(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        pause()
    }
    
    // MARK: IBActions

    @IBAction func playBtnTapped(_ sender: Any) {
        play()
    }
    
    @IBAction func pauseBtnTapped(_ sender: Any) {
        pause()
    }
    
    @IBAction func subtitleSwitchChanged(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            onSubtitle()
        } else {
            offSubtitle()
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: NotificationCenter

    @objc func connectPlayer(_ notificaiton: Notification) {
        playerView.player = player
    }
    
    @objc func disconnectPlayer(_ notificaiton: Notification) {
        playerView.player = nil
    }
    
    // MARK: Player Methods

    func play() {
        if !isPlaying {
            player?.play()
        }
    }
    
    func pause() {
        if isPlaying {
            player?.pause()
        }
    }
    
    func onSubtitle() {
        guard let group = playerItem?.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) else {
            return
        }
        
        let locale = Locale(identifier: "en")
        let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
        if let option = options.first {
            playerItem?.select(option, in: group)
        }
    }
    
    func offSubtitle() {
        guard let group = playerItem?.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) else {
            return
        }
        
        playerItem?.select(nil, in: group)
    }
    
    // MARK: Initialization Methods
   
    func setupPlayer() {
        guard let url = URL(string: hlsUrl!) else {
            return
        }
        
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        playerView.player = player
        playerView.videoGravity = AVLayerVideoGravity.resizeAspect
        
        play()
    }
    
    /**
     AVMutableCompositionを使用して外部のvttを読み込む場合、HLSではhlsUrlAsset.tracksが空になるので動作しない
        https://stackoverflow.com/questions/52409687/cant-able-to-get-video-tracks-from-avurlasset-for-hls-videos-m3u8-format-for
        mp4では動作する
     */
    func setupPlayerWithComposition() {
        guard let hls = URL(string: hlsUrl!) else {
            return
        }
        guard let vtt = URL(string: vttUrl!) else {
            return
        }
        
        let composition = AVMutableComposition()
        let hlsUrlAsset = AVURLAsset(url: hls)
        let textUrlAsset = AVURLAsset(url: vtt)
        
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do{
            guard hlsUrlAsset.tracks(withMediaType: .video).count > 0 else {
                return
            }

            try? videoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: hlsUrlAsset.duration),
                                             of: hlsUrlAsset.tracks(withMediaType: .video)[0],
                                             at: CMTime.zero)

            guard hlsUrlAsset.tracks(withMediaType: .audio).count > 0 else {
                return
            }
            try? audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: hlsUrlAsset.duration),
                                             of: hlsUrlAsset.tracks(withMediaType: .audio)[0],
                                             at: CMTime.zero)
        }
        
        let textTrack = composition.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            guard textUrlAsset.tracks.count > 0 else{
                return
            }
            
            textTrack?.languageCode = "en"
            try? textTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: hlsUrlAsset.duration),
                                                of: textUrlAsset.tracks(withMediaType: .text)[0],
                                                at: CMTime.zero)

        }
        
        playerItem = AVPlayerItem(asset: composition)
        player = AVPlayer(playerItem: playerItem)
        
        playerView.player = player
        playerView.videoGravity = AVLayerVideoGravity.resizeAspect
        
        play()
    }
    
    func setupAirPlay() {
        let routePickerView = AVRoutePickerView(frame: CGRect(x: 0, y: 10, width: 50, height: 50))
        self.view.addSubview(routePickerView)
    }
    
    func addRemoteCommand() {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        
        remoteCommandCenter.playCommand.addTarget(handler: { (event) in
            self.play()
            return MPRemoteCommandHandlerStatus.success})
        remoteCommandCenter.pauseCommand.addTarget(handler: { (event) in
            self.pause()
            return MPRemoteCommandHandlerStatus.success})
        //remoteCommandCenter.seekForwardCommand.addTarget(handler: { (event) in
        //    return MPRemoteCommandHandlerStatus.success})
        //remoteCommandCenter.seekBackwardCommand.addTarget(handler: { (event) in
        //    return MPRemoteCommandHandlerStatus.success})
        
        //remoteCommandCenter.previousTrackCommand.isEnabled = false
        //remoteCommandCenter.nextTrackCommand.isEnabled = false
        //remoteCommandCenter.skipForwardCommand.isEnabled = false
        //remoteCommandCenter.skipBackwardCommand.isEnabled = false
    }
    
    func addNowPlayingInfo() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        let duration = player?.currentItem?.asset.duration.seconds
        let currentTime = player?.currentItem?.currentTime().seconds
        nowPlayingInfoCenter.nowPlayingInfo = [
            MPMediaItemPropertyTitle: "hoge",
            MPMediaItemPropertyArtist: "fuga",
            MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1.0),
            MPMediaItemPropertyPlaybackDuration: NSNumber(value: duration!),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: currentTime!)
        ]
    }
    
}
