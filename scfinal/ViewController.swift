//
//  ViewController.swift
//  scfinal
//
//  Created by Raj Ramamurthy on 5/10/15.
//  Copyright (c) 2015 Raj Ramamurthy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var classifier = SCFClassifier()
    @IBOutlet weak var activityView: UIActivityIndicatorView?
    @IBOutlet weak var estimateLabel: UILabel?

    @IBAction func trainA(sender: UIButton) {
        activityView?.startAnimating()

        // Train for 15 seconds
        let manager = SCFMotionManager.sharedInstance
        manager.gatherAccelerometerDataOnInterval(5.0, numDataPoints: 3, onComplete: { (data) in
            let transformedData = SCFMotionManager.getClassifiableDataFromRaw(data, label:"ClassA")
            self.classifier.trainWithData(transformedData)
            self.activityView?.stopAnimating()
            println("Trained with \(transformedData.count) entries")
            var alert = UIAlertController(title: nil, message: "Trained with \(transformedData.count) entries", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    @IBAction func trainB(sender: UIButton) {
        activityView?.startAnimating()

        // Train for 15 seconds
        let manager = SCFMotionManager.sharedInstance
        manager.gatherAccelerometerDataOnInterval(5.0, numDataPoints: 3, onComplete: { (data) in
            let transformedData = SCFMotionManager.getClassifiableDataFromRaw(data, label:"ClassB")
            self.classifier.trainWithData(transformedData)
            self.activityView?.stopAnimating()
            println("Trained with \(transformedData.count) entries")
            var alert = UIAlertController(title: nil, message: "Trained with \(transformedData.count) entries", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    @IBAction func getEstimate(sender: UIButton) {
        // TODO
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
