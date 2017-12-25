//
//  FoodDetailViewController.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 12/16/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.
//

import UIKit

class FoodDetailViewController: UITableViewController {
    
    var selectedFoodItem: Ingredient?
    var ccViewModel: CCViewModel?
    
    let numberFormatter = NumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.numberFormatter.numberStyle = .decimal
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        guard self.ccViewModel != nil && self.selectedFoodItem != nil else{
            return
        }

        let indicator = UIActivityIndicatorView()
        indicator.color = UIColor.black
        self.tableView.backgroundView = indicator
        indicator.startAnimating()
     
        self.ccViewModel?.fetchFoodDetails(ingredient: self.selectedFoodItem!, completionHandler: {
            indicator.stopAnimating()
            self.tableView.backgroundView = nil
            self.tableView.reloadData()
            })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.ccViewModel?.foodNutritionData = nil
        self.tableView.reloadData()
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
            return "FOOD"
        case 1:
            return "NUTRITION DETAILS"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return self.ccViewModel?.numberOfNutritionValues() ?? 0
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodDetail", for: indexPath)
            cell.textLabel?.text = self.selectedFoodItem?.foodLabel
            cell.detailTextLabel?.text = ""
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodDetail", for: indexPath)
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            let nutrition = self.ccViewModel?.nutrionAtIndexPath(indexPath)
            NSLog("\(nutrition!.label)")
            
            let detailText = numberFormatter.string(from: nutrition!.quantity)!
            
            cell.detailTextLabel?.text = "\(String(describing: detailText)) \(String(describing: nutrition!.unit))"
            cell.textLabel?.text = nutrition?.label
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodDetail", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "breakfast.png")
            cell.textLabel?.text = "Breakfast"
            return cell
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
