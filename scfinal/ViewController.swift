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
        SCFMotionManager.sharedInstance.gatherAccelerometerDataOnInterval(5.0, numDataPoints: 3, onComplete: { (data) in
            let transformedData = SCFMotionManager.getTrainingDataFromRaw(data, label:"ClassA")
            self.gotData(transformedData)
        })
        println("Got here first?")
    }

    @IBAction func trainB(sender: UIButton) {
        activityView?.startAnimating()

        // Train for 15 seconds
        SCFMotionManager.sharedInstance.gatherAccelerometerDataOnInterval(5.0, numDataPoints: 3, onComplete: { (data) in
            let transformedData = SCFMotionManager.getTrainingDataFromRaw(data, label:"ClassB")
            self.gotData(transformedData)
        })
    }

    @IBAction func getEstimate(sender: UIButton) {
        let transformedData = SCFMotionManager.getClassifiableDataFromRaw(SCFMotionManager.sharedInstance.lastData, label: "")
        let predictions = classifier.predictBatch(transformedData)
        var labelCount = ["ClassA": 0, "ClassB": 0]
        for prediction in predictions {
            labelCount[prediction!]! += 1
        }
        let predictedLabel = labelCount["ClassA"] > labelCount["ClassB"] ? "ClassA" : "ClassB"
        estimateLabel?.text = predictedLabel
    }

    func gotData(data: [NBData]) {
        self.classifier.trainWithData(data)
        println("Trained with \(data.count) entries")
        var alert = UIAlertController(title: nil, message: "Trained with \(data.count) entries", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: {() in
            self.activityView?.stopAnimating()
        })

        // Start the other updates
        SCFMotionManager.sharedInstance.getLastWindowOnInterval(5.0, numDataPoints: 100)
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
