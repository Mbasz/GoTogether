//
//  FilterViewController.swift
//  GoTogether
//
//  Created by Marta on 26/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import BEMCheckBox

class FilterViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, BEMCheckBoxDelegate {
    
    var isPublic = true
    var category = -1
    var date = -1
    var categoryContainerVC: FilterCategoryTableViewController!
    var dateContainerVC: FilterDateTableViewController!
    var filter: Filter? = nil
    weak var eventsVC: EventsTableViewController?
    
    @IBOutlet weak var friendsCheckbox: BEMCheckBox!
    @IBOutlet weak var nearbyCheckbox: BEMCheckBox!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var timeContainer: UIView!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextField.delegate = self
        friendsCheckbox.delegate = self
        friendsCheckbox.onAnimationType = .bounce
        friendsCheckbox.offAnimationType = .bounce
        nearbyCheckbox.delegate = self
        nearbyCheckbox.onAnimationType = .bounce
        nearbyCheckbox.offAnimationType = .bounce
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        tapGesture.cancelsTouchesInView = true
//        self.view.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationTextField.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            categoryContainerVC = childViewControllers[0] as! FilterCategoryTableViewController
            if friendsCheckbox.on {
                isPublic = false
            } else {
                isPublic = true
            }
            category = categoryContainerVC.selected
            dateContainerVC = childViewControllers[1] as! FilterDateTableViewController
            date = dateContainerVC.selected
            if !isPublic || locationTextField.text != "" || category != -1 || date != -1 {
                filter = Filter(isPublic: isPublic, location: locationTextField.text!, category: category, date: date)
            }
            eventsVC?.filter = filter
        }
    }
    
    @IBAction func locationTapped(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        autocompleteController.tableCellBackgroundColor = UIColor.gtBackground
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        if checkBox == nearbyCheckbox {
            if checkBox.on {
                locationTextField.text = User.current.location
                locationTextField.isUserInteractionEnabled = false
            } else {
                locationTextField.text = ""
                locationTextField.isUserInteractionEnabled = true
            }
        }
    }
    
}

extension FilterViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.locationTextField.text = place.formattedAddress
        self.locationTextField.backgroundColor = UIColor.white
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        //
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

