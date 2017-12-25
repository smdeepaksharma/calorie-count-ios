//
//  FoodMeasureViewController.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 12/8/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.
//

import UIKit

class FoodMeasureViewController: UITableViewController {
    
    var ccViewModel: CCViewModel?
    var selectedFoodItem: Food?
    var selectedMeasure: Measure?

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.saveButton.isEnabled = false
        let foodQuantityNib = UINib(nibName: "FoodQuantityCell", bundle: nil)
        tableView.register(foodQuantityNib, forCellReuseIdentifier: "foodQuantity")
    }
    
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        let indexpathForUnit = IndexPath.init(row: 0, section: 0)
        var quantity: String? = nil
        if let quantityCell = tableView.cellForRow(at: indexpathForUnit) as? FoodQuantityCell {
            quantity = quantityCell.quantity.text!
        
        }
        
        if quantity != nil && !(quantity!.isEmpty)  {
            let ingredient = Ingredient()
            ingredient.foodUri = self.selectedFoodItem?.foodUri
            ingredient.measureUri = self.selectedMeasure?.measureUri
            ingredient.quantity = quantity
            ingredient.foodLabel = self.selectedFoodItem?.foodLabel
            ingredient.measureLabel = self.selectedMeasure?.measureLabel
            
            self.ccViewModel?.fetchNutritionData(ingredient: ingredient, completionHandler: {
                self.backTwo()
            })
        } else {
            showAlert()
            return
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Invalid Unit", message: "Please enter number of units", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func backTwo() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
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
            return "ENTER NUMBER OF UNITS"
        case 1:
            return "SELECT MEASURE"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.ccViewModel!.numberOfMeasures()
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodQuantity", for: indexPath)
             return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "measureCell", for: indexPath)
            cell.textLabel?.text = self.ccViewModel!.titleForMeasureAtIndexPath(indexPath)?.measureLabel
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            self.saveButton.isEnabled = true
            self.selectedMeasure = ccViewModel?.titleForMeasureAtIndexPath(indexPath)
        default:
            return 
        }
    }
}
