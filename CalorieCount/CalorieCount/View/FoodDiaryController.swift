//
//  FoodListController.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 12/2/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.
//

import UIKit

class FoodDiaryController: UITableViewController {
    
    var titleText: String?
    var ccViewModel: CCViewModel?
    var foodList: [Ingredient]?
    var statsList : [StatsWrapper]?
    var selectedFoodItem: Ingredient?
    var mode: String = "camera"
    
    let numberFormatter = NumberFormatter()

    @IBOutlet weak var noFoodsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

        if let title = titleText {
             self.navigationItem.title = title
        }
        self.numberFormatter.numberStyle = .decimal
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.ccViewModel?.fetchStatsForSelectedMeal(completion: { success in
            if success {
                self.tableView.reloadData()
            }
        })
        self.ccViewModel?.fetchMyFoodList(completion: { (success) in
            if success {
                self.noFoodsLabel.isHidden = true
            } else {
                self.showEmptyMessage()
            }
            self.tableView.reloadData()
        })
    }
    
    
    @IBAction func launchCameraMode(_ sender: UIBarButtonItem) {
        prepareModeSegue(mode: "camera")
    }
    
    @IBAction func launchBarcodeScannerMode(_ sender: UIBarButtonItem) {
        prepareModeSegue(mode: "barcode")
    }
    
    @IBAction func launchTextSearchMode(_ sender: UIBarButtonItem) {
        prepareModeSegue(mode: "textsearch")
    }
    
    func prepareModeSegue(mode: String) {
        self.mode = mode
        performSegue(withIdentifier: "mode", sender: self)
    }
    
 
    func showEmptyMessage() {
       self.noFoodsLabel.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "STATS FOR DATE : \(self.ccViewModel!.selectedDate!)"
        default:
            return "MY FOOD LIST"
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        case 1:
            return true
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.ccViewModel?.deleteFoodItemAtIndexPath(indexPath: indexPath, completionHandler: {
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                
                self.ccViewModel?.fetchStatsForSelectedMeal(completion: { (success) in
                    if success {
                        if (self.ccViewModel?.myFoodList?.isEmpty)! {
                            self.showEmptyMessage()
                        }
                        tableView.reloadData()
                    }
                    })
                })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.ccViewModel?.numberOfStatValues() ?? 0
        case 1:
            return self.ccViewModel?.numberOfItemInMyFoodList() ?? 0
        default:
            return 0
        }
       
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodDiaryCell", for: indexPath)
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.text = self.ccViewModel?.titleForStatAtIndexPath(indexPath)?.statLabel
            let value = self.ccViewModel?.titleForStatAtIndexPath(indexPath)?.statValue ?? 0
            let svalue = numberFormatter.string(from: value)
            var unit : String = ""
            if self.ccViewModel?.titleForStatAtIndexPath(indexPath)?.statLabel == "Calorie" {
                unit = "kcal"
            } else {
                unit = "g"
                }
            
            cell.detailTextLabel?.text = "\(svalue!) \(unit)"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodDiaryCell", for: indexPath)
            cell.textLabel?.text = self.ccViewModel?.titleForFoodItemInMyFoodListAtIndexPath(indexPath)
            cell.detailTextLabel?.text = nil
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectedFoodItem = self.ccViewModel?.myFoodList![indexPath.row]
            performSegue(withIdentifier: "detail", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mode" {
            let destination = segue.destination as! FoodItemViewController
            destination.mode = self.mode
            destination.ccViewModel = self.ccViewModel
        }
        
        if segue.identifier == "detail" {
            let destination = segue.destination as! FoodDetailViewController
            destination.selectedFoodItem = self.selectedFoodItem!
             destination.ccViewModel = self.ccViewModel
        }
    }
}
