//
//  AVPlayerSampleViewController.swift
//  AVPlayerSample
//
//  Created by 渡辺幹人 on 2019/05/03.
//  Copyright © 2019 渡辺幹人. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerSampleViewController: UIViewController {

    @IBOutlet weak var playerView: PlayerView!
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }
    
    var hlsUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: hlsUrl!) else {
            return
        }

        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        playerView.player = player
        playerView.videoGravity = AVLayerVideoGravity.resizeAspect
        player?.play()
    }
    

    @IBAction func playBtnTapped(_ sender: Any) {
        if !isPlaying {
            player?.play()
        }
    }
    
    @IBAction func pauseBtnTapped(_ sender: Any) {
        if isPlaying {
            player?.pause()
        }
    }
    
    @IBAction func subtitleSwitchChanged(_ sender: Any) {
        guard let group = playerItem?.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) else {
            return
        }
        if (sender as! UISwitch).isOn {
            // 字幕をONに
            let locale = Locale(identifier: "en")
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if let option = options.first {
                playerItem?.select(option, in: group)
            }
        } else {
            // 字幕をOFFに
            playerItem?.select(nil, in: group)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
