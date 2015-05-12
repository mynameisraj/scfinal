//
//  ViewController.swift
//  scfinal
//
//  Created by Raj Ramamurthy on 5/10/15.
//  Copyright (c) 2015 Raj Ramamurthy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let manager = SCFMotionManager.sharedInstance
        manager.gatherAccelerometerDataOnInterval(5.0, numDataPoints: 3, onComplete: { (data) in
            println("\(data)")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
