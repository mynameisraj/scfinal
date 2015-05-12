//
//  SCFMotionManager.swift
//  scfinal
//
//  Created by Raj Ramamurthy on 5/11/15.
//  Copyright (c) 2015 Raj Ramamurthy. All rights reserved.
//

import UIKit
import CoreMotion

// Maximum update interval, in seconds
let maxInterval = 0.1
// Threshold of 2-norm difference to determine if device is still
let fixedLocationThreshold = 0.0003

// Get the 2-norm of an accelerometer vector
func accelNorm(accel: CMAccelerometerData) -> Double {
    let x = accel.acceleration.x
    let y = accel.acceleration.y
    let z = accel.acceleration.z
    return sqrt(x*x + y*y + z*z)
}

func stdDev(arr: [Double]) -> Double {
    let length = Double(arr.count)
    let avg = arr.reduce(0, combine: {$0 + $1}) / length
    let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, combine: {$0 + $1})
    return sqrt(sumOfSquaredAvgDiff / length)
}

func arrMean(arr: [Double]) -> Double {
    return arr.reduce(0, combine: {$0 + $1}) / Double(arr.count)
}

class SCFMotionManager: NSObject {

    static let sharedInstance = SCFMotionManager()
    static let manager = CMMotionManager()

    override init() {
        super.init()

        SCFMotionManager.manager.accelerometerUpdateInterval = maxInterval
    }

    // Transform data from this format to a classifiable format
    func transformData(data: [[CMAccelerometerData]]) {
        
    }

    func gatherAccelerometerDataOnInterval(interval: NSTimeInterval, numDataPoints: Int, onComplete: [[CMAccelerometerData]] -> ()) {
        let startDate = NSDate()
        var allData = [[CMAccelerometerData]]()

        var currentList = [CMAccelerometerData]()
        var queue = NSOperationQueue()
        SCFMotionManager.manager.startAccelerometerUpdatesToQueue(queue, withHandler: { (data, error) in
            if allData.count > numDataPoints {
                SCFMotionManager.manager.stopAccelerometerUpdates()
                onComplete(allData)
            }
            if startDate.timeIntervalSinceNow * -1 > interval {
                let curr = currentList
                allData.append(curr)
                currentList.removeAll()
            }
            currentList.append(data)
        })
    }

    func waitForFixedLocation(timeout: NSTimeInterval, onComplete: Bool -> ()) {
        SCFMotionManager.manager.startAccelerometerUpdates()

        let startDate = NSDate()
        var withinDelta = false
        var lastData: CMAccelerometerData?
        while (!withinDelta) {
            if (startDate.timeIntervalSinceNow < -1*timeout) {
                break
            }

            if (lastData == nil) {
                lastData = SCFMotionManager.manager.accelerometerData
                continue
            }

            // Get the two norm and check the difference
            let currData = SCFMotionManager.manager.accelerometerData
            let normDiff = abs(accelNorm(currData) - accelNorm(lastData!))
            if (normDiff > 0 && normDiff < fixedLocationThreshold) {
                withinDelta = true
                println("Got a delta of \(normDiff)")
                break
            } 

            if (lastData != currData) {
                lastData = SCFMotionManager.manager.accelerometerData
            }
        }

        SCFMotionManager.manager.stopAccelerometerUpdates()
        onComplete(withinDelta)
    }
    
}
