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

        // Train for 30 seconds
        SCFMotionManager.sharedInstance.gatherAccelerometerDataOnInterval(5.0, numDataPoints: 6, onComplete: { (data) in
            let transformedData = SCFMotionManager.getTrainingDataFromRaw(data, label:"ClassA")
            self.gotData(transformedData)
        })
    }

    @IBAction func trainB(sender: UIButton) {
        activityView?.startAnimating()

        // Train for 30 seconds
        SCFMotionManager.sharedInstance.gatherAccelerometerDataOnInterval(5.0, numDataPoints: 6, onComplete: { (data) in
            let transformedData = SCFMotionManager.getTrainingDataFromRaw(data, label:"ClassB")
            self.gotData(transformedData)
        })
    }

    @IBAction func getEstimate(sender: UIButton) {
        SCFMotionManager.sharedInstance.gatherAccelerometerDataOnInterval(5.0, numDataPoints: 6, onComplete: { (data) in
            let transformedData = SCFMotionManager.getClassifiableDataFromRaw(data)
            let predictions = self.classifier.predictBatch(transformedData)
            var labelCount = ["ClassA": 0, "ClassB": 0]
            for prediction in predictions {
                labelCount[prediction!]! += 1
            }
            let predictedLabel = labelCount["ClassA"] > labelCount["ClassB"] ? "ClassA" : "ClassB"
            self.estimateLabel?.text = predictedLabel
        })
    }

    func gotData(data: [NBData]) {
        classifier.trainWithData(data)
        println("Trained with \(data.count) entries")
        var alert = UIAlertController(title: nil, message: "Trained with \(classifier.allData.count) entries", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: {() in
            activityView?.stopAnimating()
        })
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
