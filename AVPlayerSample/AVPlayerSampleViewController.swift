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
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }
    
    var hlsUrl: String?
    
    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayer()
        
        addRemoteCommand()
        addNowPlayingInfo()
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
