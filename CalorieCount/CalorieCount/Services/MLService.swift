//
//  MLService.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 12/3/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.

// The ML Model used can be foun in the below link
// Reference: https://github.com/likedan/Awesome-CoreML-Models

import UIKit

class MLService: NSObject {
    
    func predictItem(_ image: UIImage) -> String? {
    
        guard let imageData = image.pixelBuffer(width: 299, height: 299) else {
            NSLog("invalid size")
            return nil
        }
        let model = Food101()
        do {
            let output = try model.prediction(image: imageData)
            NSLog(output.classLabel.replacingOccurrences(of: "_", with: " "))
            let foodLabel = output.classLabel.replacingOccurrences(of: "_", with: " ")
            return foodLabel
        }
        catch {
            NSLog(error.localizedDescription)
            return nil
        }
    }
}
