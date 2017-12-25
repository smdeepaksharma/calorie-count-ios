//
//  CCViewModel.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 11/30/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.
//

import UIKit

class CCViewModel: NSObject {
    
    @IBOutlet var mlService: MLService!
    @IBOutlet var webService: WebService!
    @IBOutlet weak var databaseService: DatabaseService!
    
    let numberOfSectionsInFoodItemsView = 2
    
    var foodSuggestionList: [Food]?
    var foodNutritionData: [Nutrients]?
    var measures: [Measure]?
    var selectedMealType: String?
    var selectedDate: String?
    
    var myFoodList : [Ingredient]?
    var statsWrapper: [StatsWrapper] = [StatsWrapper.init("Calorie",0), StatsWrapper.init("Fat",0),StatsWrapper.init("Protein",0),StatsWrapper.init("Carb",0)]
    
    func fetchCurrentDayStats(date: String) -> Stats {
        let databaseService = DatabaseService()
        do {
            try databaseService.open()
            try databaseService.createStatsTable()
           return try databaseService.fetchStatsFor(date: date)!
        } catch {
            NSLog("No stats")
        }
        return Stats()
    }
    
    func fetchStatsFor(date: String, onStatsFeteched: @escaping (_ stats: Stats?) -> ()) {
        do {
            if !databaseService.isOpen() {
                try databaseService.open()
                try databaseService.createStatsTable()
                let stats = try databaseService.fetchStatsFor(date: date)
                
                if stats != nil {
                    onStatsFeteched(stats!)
                } else {
                    onStatsFeteched(nil)
                }
            }
        } catch {
            onStatsFeteched(nil)
            NSLog("Error: \(error)")
        }
        
    }
    
    func predictItem(_ image: UIImage, completionHandler: @escaping (_ success: Bool) -> ()) {
        if let foodItem = mlService.predictItem(image) {
            webService.fetchFoodList(foodItem, completion: { list in
                if let foodList = list {
                    self.foodSuggestionList = foodList
                     self.measures = self.foodSuggestionList?.first?.measurement
                    if !(self.foodSuggestionList?.isEmpty)! {
                        completionHandler(true)
                    }
                } else {
                    completionHandler(false)
                }
            })
        } else {
            completionHandler(false)
        }
    }
    
    func fetchFoodListByBarCode(_ code: String, completionHandler:@escaping (_ success: Bool) -> ()) {
        webService.fetchFoodListByUPC(code, completion: { list in
            if let foodList = list {
                self.foodSuggestionList = foodList
                self.measures = self.foodSuggestionList?.first?.measurement
                if !(self.foodSuggestionList?.isEmpty)! {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            } else {
                completionHandler(false)
            }
         })
    }
    
    func searchFoodItem(_ description: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        webService.fetchFoodList(description, completion: { list in
            if let foodList = list {
                self.foodSuggestionList = foodList
                self.measures = self.foodSuggestionList?.first?.measurement
                if !(self.foodSuggestionList?.isEmpty)! {
                    completionHandler(true)
                }
            } else {
                completionHandler(false)
            }
        })
    }
    
    
    func fetchNutritionData(ingredient: Ingredient,  completionHandler: @escaping () -> ()) {
        webService.fetchNutritionDetailsOf(ingredient:ingredient, completionHandler: { stats, ingredient, _ in
            let databaseService = DatabaseService()
            do {
               try databaseService.open()
               try databaseService.createStatsTable()
                if stats != nil && ingredient != nil && self.selectedMealType != nil && self.selectedDate != nil {
                    let success = try databaseService.saveMeal(type: self.selectedMealType!, date: self.selectedDate!, stats: stats!, ingredient: ingredient!)
                    if success {
                        completionHandler()
                    } else {
                        completionHandler()
                    }
                } else {
                    completionHandler()
                }
            } catch {
                NSLog("Error: \(error)")
                completionHandler()
            }
        })
    }
    
    
    func fetchMyFoodList(completion: @escaping (_ success: Bool) ->()) {
        do {
            if !databaseService.isOpen() {
                try databaseService.open()
                try databaseService.createStatsTable()
            }
            if let foodList = try self.databaseService.fetchFoodList(ofMeal: self.selectedMealType!, forDate: self.selectedDate!)
            {
                if foodList.isEmpty {
                    self.myFoodList = nil
                    completion(false)
                } else {
                    self.myFoodList = foodList
                    NSLog("\(self.myFoodList!.count)")
                    completion(true)
                }
            } else {
                completion(false)
            }
        } catch {
            NSLog("Error: \(error)")
            completion(false)
        }
    }
    
    func fetchStatsForSelectedMeal(completion: @escaping (_ success: Bool) -> ()) {
        do {
            if !databaseService.isOpen() {
                try databaseService.open()
                try databaseService.createStatsTable()
            }
            if let stats = try self.databaseService.fetchStats(ofMeal: self.selectedMealType!, forDate: self.selectedDate!)
            {
                if stats.isEmpty {
                    completion(false)
                } else {
                    self.statsWrapper = stats
                    completion(true)
                }
            } else {
                completion(false)
            }
        } catch {
            NSLog("Error: \(error)")
            completion(false)
        }
    }
    
    func fetchFoodDetails(ingredient: Ingredient, completionHandler: @escaping () -> ()) {
        webService.fetchNutritionDetailsOf(ingredient:ingredient, completionHandler: { stats, ingredient, nutrients in
            if nutrients != nil {
                self.foodNutritionData = nutrients!
                completionHandler()
            } else {
                completionHandler()
            }
        })
    }
    
    
    func deleteFoodItemAtIndexPath(indexPath: IndexPath, completionHandler: @escaping () -> ()) {
        do {
            if !databaseService.isOpen() {
                try databaseService.open()
                try databaseService.createStatsTable()
            }
            
            let foodItem = self.myFoodList![indexPath.row].foodLabel
            
            let success = try databaseService.deleteFood(itemName: foodItem!, date: self.selectedDate!, meal: self.selectedMealType!)
            if success {
                self.myFoodList?.remove(at: indexPath.row)
                completionHandler()
            }
        } catch {
            print("\(error)")
        }
    }
    
    func numberOfItemInMyFoodList() -> Int {
        return self.myFoodList?.count ?? 0
    }
    
    func numberOfStatValues() -> Int {
       return self.statsWrapper.count
    }
    
    func titleForStatAtIndexPath(_ indexPath: IndexPath) -> StatsWrapper? {
        return self.statsWrapper[indexPath.row]
    }
    
    func numberOfFoodItems() -> Int {
        return self.foodSuggestionList?.count ?? 0
    }
    
    func titleForFoodItemInMyFoodListAtIndexPath(_ indexPath: IndexPath) -> String? {
        return self.myFoodList?[indexPath.row].foodLabel
    }
    
    func titleForItemAtIndexPath(_ indexPath: IndexPath) -> Food? {
        return foodSuggestionList?[indexPath.row] 
    }

    func measuresForItemAtIndexPath(_ indexPath: IndexPath) {
        self.measures = foodSuggestionList![indexPath.row].measurement!
    }
    
    func numberOfMeasures() -> Int {
        return self.measures?.count ?? 0
    }

    func titleForMeasureAtIndexPath(_ indexPath: IndexPath) -> Measure? {
        return self.measures![indexPath.row]
    }
    
    func setSelectedMeal(type: String) {
        self.selectedMealType = type
    }
    
    func setSelectedDate(date: String) {
        self.selectedDate = date
    }
    
    func numberOfNutritionValues() -> Int {
        return self.foodNutritionData?.count ?? 0
    }
    
    func nutrionAtIndexPath(_ indexPath: IndexPath) -> Nutrients? {
        return self.foodNutritionData?[indexPath.row]
    }
    
}
