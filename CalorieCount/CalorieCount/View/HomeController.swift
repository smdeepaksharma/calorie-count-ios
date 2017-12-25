//
//  HomeController.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 11/30/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.
//

import UIKit

class HomeController: UITableViewController {

    @IBOutlet weak var currentDate: UITextField!
    let datePickerView = UIDatePicker()
    let formatter = DateFormatter()
    
    @IBOutlet var ccViewModel: CCViewModel!
    
    @IBOutlet weak var calorieCount: UILabel!
    @IBOutlet weak var fat: UILabel!
    @IBOutlet weak var protein: UILabel!
    @IBOutlet weak var carbs: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerView.datePickerMode = .date
        datePickerView.addTarget(self, action: #selector(HomeController.handleDatePicker(sender:)), for: .valueChanged)
        formatter.dateStyle = .medium
        currentDate.inputView = datePickerView
        currentDate.text = formatter.string(from: Date())
        createDatePickerToolbar()
        currentDate.endFloatingCursor()
    
        // fetch current days stats
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
         displayStatsFor(day: currentDate.text!)
    }
    
    func displayStatsFor(day: String) {
        let stats = self.ccViewModel.fetchCurrentDayStats(date: currentDate.text!)
        
        NSLog("\(stats.calorieCount) \(stats.fat) \(stats.protein) \(stats.carbs)")
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        calorieCount.text = "\(stats.calorieCount) kcal"
        fat.text = "\(numberFormatter.string(from: stats.fat) ?? "0") g"
        protein.text = "\(numberFormatter.string(from: stats.protein) ?? "0") g"
        carbs.text = "\(numberFormatter.string(from: stats.carbs) ?? "0") g"
    }
    
    @objc(handleDatePicker:)
    func handleDatePicker(sender: UIDatePicker) {
        currentDate.text = formatter.string(from: sender.date)
    }
    
    func createDatePickerToolbar() {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.black
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(HomeController.done))
        toolbar.setItems([doneButton], animated: true)
        currentDate.inputAccessoryView = toolbar
    }
    
    @objc func done() {
         displayStatsFor(day: self.currentDate.text!)
        currentDate.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            ccViewModel.selectedMealType = "Breakfast"
        case 1:
            ccViewModel.selectedMealType = "Lunch"
        case 2:
            ccViewModel.selectedMealType = "Dinner"
        default:
            ccViewModel.selectedMealType = "Breakfast"
        }
        ccViewModel.selectedDate = currentDate.text
        performSegue(withIdentifier: "foodList", sender: self)
    }

  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "foodList" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! FoodDiaryController
                switch indexPath.row {
                case 0: destination.titleText = "Breakfast"
                case 1: destination.titleText = "Lunch"
                case 2: destination.titleText = "Dinner"
                default: destination.titleText = "Meal"
                }
                destination.ccViewModel = self.ccViewModel
            }
        }
    }
}
