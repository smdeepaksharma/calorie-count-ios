//
//  WebService.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 12/3/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class WebService: NSObject {
    
    var APP_ID: String = "352b334c"
    var APP_KEY: String = "f7b30679380c6fbf009aee8f019bd308"
    
    func fetchFoodList(_ itemName: String, completion: @escaping ([Food]?) -> ()) {
        let url = "https://api.edamam.com/api/food-database/parser?ingr=\(itemName)&app_id=\(self.APP_ID)&app_key=\(APP_KEY)&page=0"
        let headers : HTTPHeaders = ["Content-Type" : "application/json", "Accept-Charset":"UTF-8"]
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        if encodedUrl != nil {
            Alamofire.request(encodedUrl!, encoding: JSONEncoding.default, headers: headers).validate()
                .responseJSON { response in
    
                    if let status = response.response?.statusCode {
                        guard status == 200 else {
                            completion(nil)
                            return
                        }
                    }
                    switch response.result {
                    case .success:
                        if let responseValue = response.result.value {
                            let jsonResponse = JSON(responseValue)
                            let hints = jsonResponse["hints"].arrayValue
                            
                            guard hints.count > 0 else {
                                completion(nil)
                                return
                            }
                            
                            var suggestions: [Food] = []
                            for hint in hints {
                                let measures = JSON(hint["measures"]).arrayValue
                                var foodMeassures : [Measure] = []
                                for m in measures {
                                    let measure = Measure()
                                    measure.measureLabel = m["label"].string ?? nil
                                    measure.measureUri = m["uri"].string ?? nil
                                    foodMeassures.append(measure)
                                }
                                let food = Food()
                                food.foodLabel = hint["food"]["label"].string!
                                food.foodUri = hint["food"]["uri"].string!
                                food.measurement = foodMeassures
                                suggestions.append(food)
                            }
                            completion(suggestions)
                        }
                    case .failure(let error):
                         print(error)
                         completion(nil)
                }
            }
        }
    }
    
    func fetchFoodListByUPC(_ itemName: String, completion: @escaping ([Food]?) -> ()) {
        let url = "https://api.edamam.com/api/food-database/parser?upc=\(itemName)&app_id=\(self.APP_ID)&app_key=\(APP_KEY)&page=0"
         let headers : HTTPHeaders = ["Content-Type" : "application/json", "Accept-Charset":"UTF-8"]
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        if encodedUrl != nil {
            Alamofire.request(encodedUrl!, encoding: JSONEncoding.default, headers: headers).validate()
                .responseJSON { response in
            
                    if let status = response.response?.statusCode {
                        guard status == 200 else {
                            completion(nil)
                            return
                        }
                    }
                    switch response.result {
                    case .success:
                        if let responseValue = response.result.value {
                            let jsonResponse = JSON(responseValue)
                            let hints = jsonResponse["hints"].arrayValue
                            var suggestions: [Food] = []
                            for hint in hints {
                                let measures = JSON(hint["measures"]).arrayValue
                                var foodMeassures : [Measure] = []
                                for m in measures {
                                    let measure = Measure()
                                    measure.measureLabel = m["label"].string!
                                    measure.measureUri = m["uri"].string!
                                    foodMeassures.append(measure)
                                }
                                let food = Food()
                                food.foodLabel = hint["food"]["label"].string!
                                food.foodUri = hint["food"]["uri"].string!
                                food.measurement = foodMeassures
                                suggestions.append(food)
                            }
                            completion(suggestions)
                        }
                    case .failure(let error):
                        print(error)
                        completion(nil)
                    }
            }
        }
    }
    
    
    func fetchNutritionDetailsOf(ingredient: Ingredient, completionHandler: @escaping (_ stats: Stats?, _ ingredent: Ingredient?, _ nutrients: [Nutrients]?) -> ()) {
        let url = "https://api.edamam.com/api/food-database/nutrients?app_id=\(APP_ID)&app_key=\(APP_KEY)"
        let paramters: [String: Any] =  [
            "yield": 1,
            "ingredients" : [[
                "quantity": NSNumber.init(value: Float(ingredient.quantity!)!),
                "measureURI": ingredient.measureUri!,
                "foodURI": ingredient.foodUri!
                ]]
         ]
        let headers : HTTPHeaders = ["Content-Type" : "application/json", "Accept-Charset":"UTF-8"]
        Alamofire.request(url, method: .post, parameters: paramters, encoding: JSONEncoding.default, headers: headers)
        .validate()
            .responseData { response in
                
                let dataString = NSString(data: response.data!, encoding: String.Encoding.isoLatin1.rawValue)
                let data =  dataString!.data(using: String.Encoding.utf8.rawValue)
            
                switch response.result {
                case .success:
                    if let responseValue = data {
                        let jsonResponse = JSON(responseValue)
                        let totalNutrients = jsonResponse["totalNutrients"].dictionaryValue
                        let stats = Stats()
                        stats.calorieCount = jsonResponse["calories"].number ?? 0
                        if let fat = totalNutrients["FAT"] {
                           stats.fat = fat["quantity"].number ?? 0
                        } 
                        if let protein = totalNutrients["PROCNT"] {
                            stats.protein = protein["quantity"].number ?? 0
                        }
                        if let carbs = totalNutrients["CHOCDF"] {
                            stats.carbs = carbs["quantity"].number ?? 0
                        }
                        var nutrients : [Nutrients] = []
                        for (_, value) in totalNutrients {
                            let nutrient = Nutrients.init(nutrient: value.dictionaryObject!)
                            nutrients.append(nutrient)
                        }
                        completionHandler(stats, ingredient, nutrients)
                    }
                case .failure(let error):
                    print(error)
                    completionHandler(nil, nil, nil)
                }
            }
        }
}

