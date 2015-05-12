//
//  NaiveBayes.swift
//  scfinal
//
//  Created by Raj Ramamurthy on 5/12/15.
//  Copyright (c) 2015 Raj Ramamurthy. All rights reserved.
//

import Foundation

struct NBData {
    var label: String
    var features: [String]
}

class NaiveBayes {

    // Used for Laplacian smoothing
    private let smoothingConstant = 1.0
    // When the value cannot be found, use this instead of 0 to avoid error
    private let defaultLog = 0.0000000000001
    private var labelCount = [String: Int]()
    private var features = Set<String>()
    private var probs = [String: [String: Double]]()
    private var priors = [String: Double]()

    // Train using the given data
    func trainWithData(data: [NBData]) {
        // Gather information on the training data set
        for item in data {
            let labelCountTemp = labelCount[item.label] ?? 0
            labelCount[item.label] = labelCountTemp + item.features.count

            // Initialize probabilities if necessary
            if probs[item.label] == nil {
                probs[item.label] = [:]
            }

            for feature in item.features {
                features.insert(feature)
                let count = probs[item.label]![feature] ?? smoothingConstant
                probs[item.label]![feature] = count + 1
            }
        }

        // Compute probabilities based on values
        for label in labelCount.keys {
            let totalSum = Double(labelCount[label]! + features.count)
            for feature in probs[label]!.keys {
                let count = probs[label]![feature] ?? smoothingConstant
                probs[label]![feature] = count / totalSum
            }
        }

        // Compute priors
        for label in labelCount.keys {
            var totalLabelCount = 0
            for labelVal in labelCount.values {
                totalLabelCount += labelVal
            }
            if (totalLabelCount == 0) {
                priors[label] = 0.0
            } else {
                priors[label] = Double(labelCount[label]!) / Double(totalLabelCount)
            }
        }
    }

    // Predict a value assuming its class is unknown
    func predict(item: [String]) -> String? {
        var result = [String: Double]()
        for label in probs.keys {
            result[label] = log((priors[label])!)
            for feature in item {
                var logVal = defaultLog
                if probs[label]![feature] != nil {
                    logVal = log(probs[label]![feature]!)
                } else {
                    logVal = log(logVal)
                }
                result[label]! += logVal
            }
        }

        var maxNumber: Double?
        var maxLabel: String?
        for (key, number) in result {
            if (maxNumber == nil || number > maxNumber) {
                maxNumber = number
                maxLabel = key
            }
        }
        return maxLabel
    }

}
