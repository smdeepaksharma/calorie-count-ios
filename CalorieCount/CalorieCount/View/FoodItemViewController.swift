//
//  FoodItemViewController.swift
//  CalorieCount
//
//  Created by Deepak Sharma S M on 12/3/17.
//  Copyright © 2017 Deepak Sharma S M. All rights reserved.
//

import UIKit
import BarcodeScanner

class FoodItemViewController: UITableViewController, UISearchResultsUpdating , UISearchBarDelegate, UISearchControllerDelegate {
    
    var itemImage: UIImage?
    var ccViewModel: CCViewModel?
    var mode: String?
    var barcode: String?
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    
    let activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let foodImageNib = UINib(nibName: "FoodImageCell", bundle: nil)
        let foodLabelNib = UINib(nibName: "FoodLabelViewCell", bundle: nil)
        tableView.register(foodImageNib, forCellReuseIdentifier: "foodImage")
        tableView.register(foodLabelNib, forCellReuseIdentifier: "foodLabel")
        
        self.activityIndicator.color = UIColor.black
        self.activityIndicator.hidesWhenStopped = true
        
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.delegate = self
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.launchMode()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            self.ccViewModel!.searchFoodItem(searchBar.text!, completionHandler: { success in
                if success {
                    self.tableView.tableHeaderView?.isHidden = true
                    self.tableView.tableFooterView?.isHidden = true
                    self.tableView.reloadData()
                    self.searchController.resignFirstResponder()
                } else {
                    self.tableView.tableHeaderView?.isHidden = false
                    self.tableView.tableFooterView?.isHidden = false
                }
                self.searchController.searchBar.resignFirstResponder()
            })
        }
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.ccViewModel?.foodSuggestionList = nil
        self.tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
        }
    }
    

    func launchMode() {
        switch mode! {
        case "camera":
            launchImagePicker()
            break
        case "barcode":
            launchBarcodeScanner()
            break
        default: NSLog("text search mode")
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func launchImagePicker() {
        let imagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
        }
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func launchBarcodeScanner() {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        controller.title = "Barcode Scanner"
        present(controller, animated: true, completion: nil)
    }
    
    func processImage(_ image: UIImage) {
        self.itemImage = image
   
        self.tableView.backgroundView = self.activityIndicator
        self.showProgress()
        self.tableView.reloadData()
        self.ccViewModel!.predictItem(image, completionHandler: { success in
            self.hideProgress()
            if success {
                self.tableView.tableHeaderView?.isHidden = true
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.reloadData()
            } else {
                self.tableView.tableHeaderView?.isHidden = false
                self.tableView.tableFooterView?.isHidden = false
            }
        })
    }
    
    func processBarcode(_ code: String) {
        self.ccViewModel?.fetchFoodListByBarCode(code, completionHandler: { success in
            if success {
                self.tableView.tableHeaderView?.isHidden = true
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.reloadData()
            } else {
                self.tableView.tableHeaderView?.isHidden = false
                self.tableView.tableFooterView?.isHidden = false
            }
        })
    }
    
    func showProgress() {
        self.activityIndicator.startAnimating()
    }
    
    func hideProgress() {
        self.activityIndicator.stopAnimating()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.ccViewModel!.numberOfFoodItems()
        default:
            return 0
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.ccViewModel!.numberOfSectionsInFoodItemsView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if self.mode! == "camera" {
                return 250
            } else {
                return 50
            }
        case 1:
            return 50
        default:
            return 50
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            if self.ccViewModel?.foodSuggestionList != nil {
                if self.ccViewModel!.foodSuggestionList!.count > 0 {
                    return "SEARCH SUGGESTION"
                } else {
                    return nil
                }
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            
            switch self.mode! {
            case "camera":
                let cell = tableView.dequeueReusableCell(withIdentifier: "foodImage") as! FoodImageCell
                cell.foodImage.image = self.itemImage
                return cell
            case "barcode":
                let labelCell = tableView.dequeueReusableCell(withIdentifier: "foodLabel") as! FoodLabelViewCell
                labelCell.foodLabel.text = "UPC Code: \(self.barcode ?? "")"
                return labelCell
            case "textsearch":
                let labelCell = tableView.dequeueReusableCell(withIdentifier: "foodLabel") as! FoodLabelViewCell
                labelCell.foodLabel.text = nil
                return labelCell
            default:
                let labelCell = tableView.dequeueReusableCell(withIdentifier: "foodLabel") as! FoodLabelViewCell
                labelCell.foodLabel.text = nil
                return labelCell
            }
        case 1:
            let labelCell = tableView.dequeueReusableCell(withIdentifier: "foodLabel") as! FoodLabelViewCell
            labelCell.foodLabel.text = self.ccViewModel!.titleForItemAtIndexPath(indexPath)?.foodLabel!
            return labelCell
        default:
            let labelCell = tableView.dequeueReusableCell(withIdentifier: "foodLabel") as! FoodLabelViewCell
            labelCell.foodLabel.text = ""
            return labelCell;
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            self.ccViewModel!.measuresForItemAtIndexPath(indexPath)
            performSegue(withIdentifier: "showMeasure", sender: self)
        default:
            return
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMeasure" {
            let destination = segue.destination as! FoodMeasureViewController
            destination.ccViewModel = self.ccViewModel
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.selectedFoodItem = self.ccViewModel!.titleForItemAtIndexPath(indexPath)
            }
            
       }
    }
}


extension FoodItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        processImage(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension FoodItemViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        print("Barcode Data: \(code)")
        print("Symbology Type: \(type)")
        self.barcode = code
        self.tableView.reloadData()
        let delayTime = DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            controller.resetWithError()
        }
        processBarcode(code)
        controller.dismiss(animated: true, completion: nil)
    }
}

extension FoodItemViewController: BarcodeScannerErrorDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
}

extension FoodItemViewController: BarcodeScannerDismissalDelegate {
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}



