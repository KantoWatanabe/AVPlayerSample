//
//  PlayerView.swift
//  AVPlayerSample
//
//  Created by 渡辺幹人 on 2019/05/03.
//  Copyright © 2019 渡辺幹人. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var videoGravity: AVLayerVideoGravity {
        get {
            return playerLayer.videoGravity
        }
        set {
            playerLayer.videoGravity = newValue
        }
    }

}
