//
//  ViewController.swift
//  AVPlayerSample
//
//  Created by 渡辺幹人 on 2019/05/03.
//  Copyright © 2019 渡辺幹人. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: IBActions
    
    @IBAction func avPlayerViewControllerBtnTapped(_ sender: Any) {
        playByAVPlayerViewController()
    }
    
    // MARK: private method
    
    // https://developer.apple.com/documentation/avfoundation/media_assets_playback_and_editing/creating_a_basic_video_player_ios_and_tvos
    private func playByAVPlayerViewController() {
        
        // https://stackoverflow.com/questions/41112283/avplayer-not-playing-m3u8-from-local-file
        // ローカルのm3u8は再生できない、mp4であれば可能
        // AndroidのExoPlayerはできてしまうが。。
        //guard let m3u8Path = Bundle.main.path(forResource: "sample", ofType: "m3u8") else {
        //    return
        //}
        
        //let avPlayer = AVPlayer(url: URL(fileURLWithPath: m3u8Path))
        
        guard let hlsUrl = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8") else {
            return
        }
        
        let avPlayer = AVPlayer(url: hlsUrl)
        
        let avPlayerViewController = AVPlayerViewController()
        avPlayerViewController.player = avPlayer
        
        self.present(avPlayerViewController, animated: true, completion: {
            avPlayer.play()
        })
    }
}

