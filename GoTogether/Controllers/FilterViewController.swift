//
//  FilterViewController.swift
//  GoTogether
//
//  Created by Marta on 26/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit

class FilterViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    var isPublic = true
    var category = -1
    var date = -1
    var categoryContainerVC: FilterCategoryTableViewController!
    var dateContainerVC: FilterDateTableViewController!
    var filter: Filter?
    weak var eventsVC: EventsTableViewController?
    
    @IBOutlet weak var publicSegmentedControl: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var timeContainer: UIView!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            categoryContainerVC = childViewControllers[0] as! FilterCategoryTableViewController
            category = categoryContainerVC.selected
            dateContainerVC = childViewControllers[1] as! FilterDateTableViewController
            date = dateContainerVC.selected
            filter = Filter(isPublic: isPublic, location: locationTextField.text!, category: category, date: date)
            eventsVC?.filter = filter
        }
    }
    
    
}
