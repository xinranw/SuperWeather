//
//  VideoViewController.swift
//  SuperWeather
//
//  Created by Wang, Xinran on 5/5/15.
//  Copyright (c) 2015 Comcast. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoViewController: UIViewController {

    var player : MPMoviePlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var url = NSURL(string: "https://s3.amazonaws.com/pluscast/vod/wcvb/master.m3u8")
        player = MPMoviePlayerController(contentURL: url)
        player.prepareToPlay()
        
        view.addSubview(player.view)
        player.view.frame = CGRectMake(0, 40, view.frame.size.width, 240)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
