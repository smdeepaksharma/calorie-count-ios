//
//  Nutrients.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 12/10/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.
//

import UIKit

class Nutrients: NSObject {
    
    var label: String
    var unit: String
    var quantity: NSNumber
    
    init(nutrient: [String: Any]) {
        label = nutrient["label"] as! String
        unit = nutrient["unit"] as! String
        quantity = nutrient["quantity"] as! NSNumber 
    }
}
