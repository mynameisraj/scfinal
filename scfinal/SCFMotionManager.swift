//
//  SCFMotionManager.swift
//  scfinal
//
//  Created by Raj Ramamurthy on 5/11/15.
//  Copyright (c) 2015 Raj Ramamurthy. All rights reserved.
//

import UIKit
import CoreMotion
import Surge

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

class SCFMotionManager: NSObject {

    static let sharedInstance = SCFMotionManager()
    static let manager = CMMotionManager()
    private var currIndex = 0
    var lastData = [[CMAccelerometerData]]()

    override init() {
        super.init()

        SCFMotionManager.manager.accelerometerUpdateInterval = maxInterval
    }

    class func getFeatureDictFromRaw(data: [CMAccelerometerData]) -> [String: Double] {
        var currDict = [String: Double]()
        // Get the data in a more usable form for mean/stddev etc
        var x = [Double]()
        var y = [Double]()
        var z = [Double]()
        for accel in data {
            x.append(accel.acceleration.x*10000)
            y.append(accel.acceleration.y*10000)
            z.append(accel.acceleration.z*10000)
        }

        // Compute FFT
        currDict["fftx"] = arrMean(fft(x))
        currDict["ffty"] = arrMean(fft(y))
        currDict["fftz"] = arrMean(fft(z))

        // Compute mean
        currDict["mx"] = arrMean(x)
        currDict["my"] = arrMean(y)
        currDict["mz"] = arrMean(z)

        // Compute standard deviation
        currDict["sx"] = sqrt(arrVar(x))
        currDict["sy"] = sqrt(arrVar(y))
        currDict["sz"] = sqrt(arrVar(z))

        return currDict
    }

    // Transform data from this format to a trainable format
    class func getTrainingDataFromRaw(data: [[CMAccelerometerData]], label: String) -> [NBData] {
        var outData = [NBData]()
        for dataList in data {
            let features = getFeatureDictFromRaw(dataList)
            let outNB = NBData(label: label, features: features)
            outData.append(outNB)
        }
        return outData
    }

    // Transform data from this format to a classifiable format
    class func getClassifiableDataFromRaw(data: [[CMAccelerometerData]]) -> [[String: Double]] {
        var outData = [[String: Double]]()
        for dataList in data {
            if (dataList.count == 0) {
                continue
            }
            let features = getFeatureDictFromRaw(dataList)
            outData.append(features)
        }
        return outData
    }

    // Continuously keep the window of data around. Must call stopAccelerometerUpdates after this
    func getLastWindowOnInterval(interval: NSTimeInterval, numDataPoints: Int) {
        for i in 0...numDataPoints-1 {
            if (lastData.count < numDataPoints) {
                lastData.append([])
            } else {
                lastData[i] = []
            }
        }
        var queue = NSOperationQueue()
        var startDate = NSDate()
        var currentList = [CMAccelerometerData]()
        SCFMotionManager.manager.startAccelerometerUpdatesToQueue(queue, withHandler: { (data, error) in
            // Some work in here
            if startDate.timeIntervalSinceNow * -1 > interval {
                let curr = currentList
                self.lastData[self.currIndex] = curr
                self.currIndex = self.currIndex == self.lastData.count ? 0 : self.currIndex+1
                startDate = NSDate()
                var date = NSDate()
                println("Now pushing to \(self.currIndex) bucket at timestamp \(date)")
            }
            currentList.append(data)
        })
    }

    func gatherAccelerometerDataOnInterval(interval: NSTimeInterval, numDataPoints: Int, onComplete: [[CMAccelerometerData]] -> ()) {
        var startDate = NSDate()
        var allData = [[CMAccelerometerData]]()

        var currentList = [CMAccelerometerData]()
        var queue = NSOperationQueue()
        // Stop all updates before we start again
        SCFMotionManager.manager.stopAccelerometerUpdates()
        SCFMotionManager.manager.startAccelerometerUpdatesToQueue(queue, withHandler: { (data, error) in
            if allData.count > numDataPoints {
                SCFMotionManager.manager.stopAccelerometerUpdates()
                onComplete(allData)
            }
            if startDate.timeIntervalSinceNow * -1 > interval {
                let curr = currentList
                allData.append(curr)
                currentList.removeAll()
                startDate = NSDate()
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
