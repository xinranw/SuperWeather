//
//  PodcastViewController.swift
//  SuperWeather
//
//  Created by Wang, Xinran on 5/5/15.
//  Copyright (c) 2015 Comcast. All rights reserved.
//

import UIKit
import AVFoundation

class PodcastViewController: UIViewController {

    var player : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        var path = NSBundle.mainBundle().pathForResource("everythingisawesome", ofType: "mp3")
        var url = NSURL(fileURLWithPath: path!)
        player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.prepareToPlay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stop(sender: AnyObject) {
        player.stop()
    }
    
    @IBAction func play(sender: AnyObject){
        player.play()
    }
}
