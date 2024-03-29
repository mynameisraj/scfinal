//
//  SCFClassifier.swift
//  scfinal
//
//  Created by Raj Ramamurthy on 5/12/15.
//  Copyright (c) 2015 Raj Ramamurthy. All rights reserved.
//

import Foundation
import Darwin

struct NBData {
    var label: String
    var features: [String: Double]
}

// Normal distribution
func getProb(meanVal: Double, varVal: Double, v: Double) -> Double {
    var d = -1*(v-meanVal)*(v-meanVal)/(2*varVal*varVal) - log(sqrt(2*M_PI*varVal*varVal))
    return d
}

func arrVar(arr: [Double]) -> Double {
    let length = Double(arr.count)
    let avg = arr.reduce(0, combine: {$0 + $1}) / length
    let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, combine: {$0 + $1})
    return sumOfSquaredAvgDiff / length
}

func arrMean(arr: [Double]) -> Double {
    return arr.reduce(0, combine: {$0 + $1}) / Double(arr.count)
}

class SCFClassifier {

    // Used for Laplacian smoothing
    private let smoothingConstant = 1.0
    // When the value cannot be found, use this instead of 0 to avoid error
    private let defaultLog = 0.0000000000001
    private var labelCount = [String: Int]()
    private var features = Set<String>()
    private var priors = [String: Double]()

    private var means = [String: [String: Double]]()
    private var variances = [String: [String: Double]]()
    var allData = [NBData]()

    var trained = false

    // P(x = v | c)
    func p(feature: String, label: String, v: Double) -> Double {
        return getProb(means[label]![feature]!, variances[label]![feature]!, v)
    }

    // Transform data into a dictionary of label:feature:values
    func calculateGaussian(data: [NBData]) {
        var outData = [String: [String: [Double]]]()
        for item in data {
            for (feature, featureValue) in item.features {
                if (outData[item.label] == nil) {
                    outData[item.label] = [:]
                }
                if (outData[item.label]![feature] == nil) {
                    outData[item.label]![feature] = [Double]()
                }
                outData[item.label]![feature]!.append(featureValue)
            }
        }

        for label in outData.keys {
            for feature in outData[label]!.keys {
                if (means[label] == nil) {
                    means[label] = [:]
                }
                means[label]![feature] = arrMean(outData[label]![feature]!)

                if (variances[label] == nil) {
                    variances[label] = [:]
                }
                variances[label]![feature] = arrVar(outData[label]![feature]!)
            }
        }
    }

    // Train using the given data
    func trainWithData(data: [NBData]) {
        // Augment our current data
        allData.extend(data)

        calculateGaussian(allData)

        // Gather information on the training data set
        for item in allData {
            let labelCountTemp = labelCount[item.label] ?? 0
            labelCount[item.label] = labelCountTemp + item.features.count

            for feature in item.features.keys {
                features.insert(feature)
            }
        }

        // Compute priors
        for label in labelCount.keys {
            var totalLabelCount = 0
            for labelVal in labelCount.values {
                totalLabelCount += labelVal
            }
            if (totalLabelCount == 0) {
                // We have no data
                priors[label] = 0.0
            } else {
                priors[label] = Double(labelCount[label]!) / Double(totalLabelCount)
            }
        }

        trained = true
    }

    // Predict a value assuming its class is unknown
    func predict(item: [String: Double]) -> String? {
        var result = [String: Double]()
        for label in labelCount.keys {
            result[label] = log(priors[label]!+0.0000000000001)
            for (feature, featureValue) in item {
                let z = p(feature, label: label, v: featureValue)
                if (z != 0) {
                    result[label] = result[label]! + log(z)
                }
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

    // Predict a large batch of data
    func predictBatch(items: [[String: Double]]) -> [String?] {
        var results = [String?]()
        for item in items {
            results.append(predict(item))
        }
        return results
    }

}
