//
//  DatabaseService.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 12/9/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.
//

import UIKit
import SQLite

enum DataError: Error {
    case NoDatabaseConnection
}

class DatabaseService: NSObject {
    
    static let dbName = "calorie.sqlite"
    static let statsTableName = "stats"
    
    static let meal = Expression<String>("meal")
    static let date = Expression<String>("date")
    static let calorie = Expression<Double>("calorie")
    static let fat = Expression<Double>("fat")
    static let protein = Expression<Double>("protein")
    static let carbs = Expression<Double>("carbs")
    static let id = Expression<Int>("id")
    static let foodLabel = Expression<String>("foodLabel")
    static let measureLabel = Expression<String>("measureLabel")
    static let foodURI = Expression<String>("foodURI")
    static let measureURI = Expression<String>("measureURI")
    static let quantity = Expression<String>("quantity")
    
    var db :Connection?
    var statsTable :Table?
    
    func databasePath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        return "\(path)/\(DatabaseService.dbName)"
    }
    
    func isOpen() -> Bool {
        return db != nil
    }
    
    func open(inMemory:Bool = false) throws {
        if inMemory {
            db = try Connection()
        } else {
            db = try Connection(databasePath())
        }
    }
    
    func createStatsTable() throws {
        if !isOpen() {
            try open()
        }
        statsTable = Table(DatabaseService.statsTableName)
        try db?.run((statsTable?.create(ifNotExists: true) { t in
            t.column(DatabaseService.date)
            t.column(DatabaseService.meal)
            t.column(DatabaseService.calorie)
            t.column(DatabaseService.fat)
            t.column(DatabaseService.protein)
            t.column(DatabaseService.carbs)
            t.column(DatabaseService.id, primaryKey: .autoincrement)
            t.column(DatabaseService.foodLabel)
            t.column(DatabaseService.foodURI)
            t.column(DatabaseService.measureURI)
            t.column(DatabaseService.measureLabel)
            t.column(DatabaseService.quantity)
            })!)
    }
    
    
   
    
    func saveMeal(type: String, date: String, stats: Stats, ingredient: Ingredient) throws -> Bool {
        guard db != nil && statsTable != nil else {
            NSLog("Db or table is null")
            throw DataError.NoDatabaseConnection
        }
        
        if let insert = statsTable?.insert(
                                       DatabaseService.meal <- type,
                                       DatabaseService.calorie <- Double(truncating: stats.calorieCount),
                                       DatabaseService.carbs <- Double(truncating: stats.carbs),
                                       DatabaseService.protein <- Double(truncating: stats.protein),
                                       DatabaseService.fat <- Double(truncating: stats.fat),
                                       DatabaseService.date <- date,
                                       DatabaseService.measureLabel <- ingredient.measureLabel!,
                                       DatabaseService.measureURI <- ingredient.measureUri!,
                                       DatabaseService.foodLabel <- ingredient.foodLabel!,
                                       DatabaseService.quantity <- ingredient.quantity!,
                                       DatabaseService.foodURI <- ingredient.foodUri!)
        {
            _ = try db?.run(insert)
        }
        return true
    }
    
    func fetchStatsFor(date: String) throws -> Stats? {
        guard db != nil && statsTable != nil else {
            throw DataError.NoDatabaseConnection
        }
        let query = statsTable!.filter( DatabaseService.date == date)
        let statsData = try db!.prepare(query)
        
        var cc: Double = 0.0
        var prtn: Double = 0.0
        var carbs: Double = 0.0
        var fat: Double = 0.0
        
        for stat in statsData {
            cc += stat[DatabaseService.calorie]
            carbs += stat[DatabaseService.carbs]
            prtn += stat[DatabaseService.protein]
            fat += stat[DatabaseService.fat]
        }
        
        let totalStats = Stats()
        totalStats.calorieCount = NSNumber(value: cc)
        totalStats.protein = NSNumber(value: prtn)
        totalStats.carbs = NSNumber(value: carbs)
        totalStats.fat = NSNumber(value: fat)
        
        return totalStats
    }
    
    
    func fetchFoodList(ofMeal meal: String, forDate date: String ) throws -> [Ingredient]? {
        
        guard db != nil && statsTable != nil else {
            throw DataError.NoDatabaseConnection
        }
        let query = statsTable!.filter( DatabaseService.date == date)
            .filter(DatabaseService.meal == meal)
        
        let result = try db?.prepare(query)
        
        guard result != nil else {
            return (nil)
        }
        
        var foodList: [Ingredient] = []
        var cc: Double = 0.0
        var prtn: Double = 0.0
        var carbs: Double = 0.0
        var fat: Double = 0.0

        for food in result! {
            let item = Ingredient()
            item.foodLabel = food[DatabaseService.foodLabel]
            item.foodUri = food[DatabaseService.foodURI]
            item.measureUri = food[DatabaseService.measureURI]
            item.measureLabel = food[DatabaseService.measureLabel]
            item.quantity = food[DatabaseService.quantity]
            foodList.append(item)
            
            cc += food[DatabaseService.calorie]
            carbs += food[DatabaseService.carbs]
            prtn += food[DatabaseService.protein]
            fat += food[DatabaseService.fat]
        }
        
        let cal = StatsWrapper("Calorie", NSNumber(value: cc))
        let fatWrapper = StatsWrapper("Fat", NSNumber(value: fat))
        let prtnWrapper = StatsWrapper("Protein",NSNumber(value: prtn))
        let carbWrapper = StatsWrapper("Carb",NSNumber(value: carbs))
        
        var totalStats : [StatsWrapper] = []
        totalStats.append(cal)
        totalStats.append(fatWrapper)
        totalStats.append(prtnWrapper)
        totalStats.append(carbWrapper)
        return foodList
    }
    
    func fetchStats(ofMeal meal: String, forDate date: String) throws -> [StatsWrapper]? {
        guard db != nil && statsTable != nil else {
            throw DataError.NoDatabaseConnection
        }
        let query = statsTable!.filter( DatabaseService.date == date)
            .filter(DatabaseService.meal == meal)
        
        let result = try db?.prepare(query)
        
        guard result != nil else {
            return (nil)
        }
        
        var cc: Double = 0.0
        var prtn: Double = 0.0
        var carbs: Double = 0.0
        var fat: Double = 0.0
        
        for food in result! {
            cc += food[DatabaseService.calorie]
            carbs += food[DatabaseService.carbs]
            prtn += food[DatabaseService.protein]
            fat += food[DatabaseService.fat]
        }
        
        let cal = StatsWrapper("Calorie", NSNumber(value: cc))
        let fatWrapper = StatsWrapper("Fat", NSNumber(value: fat))
        let prtnWrapper = StatsWrapper("Protein",NSNumber(value: prtn))
        let carbWrapper = StatsWrapper("Carb",NSNumber(value: carbs))
        
        var totalStats : [StatsWrapper] = []
        totalStats.append(cal)
        totalStats.append(fatWrapper)
        totalStats.append(prtnWrapper)
        totalStats.append(carbWrapper)
        return totalStats
    }
    
    func deleteFood(itemName: String, date: String, meal: String) throws -> Bool {
        NSLog("Inside delete")
        guard db != nil && statsTable != nil else {
            throw DataError.NoDatabaseConnection
        }
        let itemTobeDeleted = statsTable?.filter(DatabaseService.date == date).filter(DatabaseService.meal == meal).filter(DatabaseService.foodLabel == itemName)
        if let validItem = itemTobeDeleted {
            try db?.run(validItem.delete())
        } else {
            return false
        }
        return true
    }
}
