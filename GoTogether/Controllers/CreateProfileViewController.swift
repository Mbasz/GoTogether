//
//  CreateProfileViewController.swift
//  GoTogether
//
//  Created by Marta on 11/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class CreateProfileViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    let locationManager = CLLocationManager()
    var location = ""
    let firUser = Auth.auth().currentUser
    let imageHelper = GTImageHelper()
    var imgURL = ""
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location = ""
        self.checkForLocationServices()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.requestLocation()
        }
        else { }
        
        self.fullNameTextField.delegate = self
        self.locationTextField.delegate = self
        
        self.fullNameTextField.text = firUser?.displayName
        if firUser?.photoURL != nil {
            self.profileImageView.kf.setImage(with: firUser?.photoURL)
        }
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        tapGesture.cancelsTouchesInView = true
//        self.view.addGestureRecognizer(tapGesture)
        
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
//        profileImageView.isUserInteractionEnabled = true
//        profileImageView.addGestureRecognizer(tapGestureRecognizer)
//        
//        imageHelper.completionHandler = { image in
//            self.profileImageView.image = image
//        }
        
        nextButton.layer.cornerRadius = 5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return false
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imageHelper.presentImagePickerController(with: .photoLibrary, from: self)
        }
    }

    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        guard let name = fullNameTextField.text, let location = locationTextField.text, !name.isEmpty, !location.isEmpty
            else { return }
        
        if firUser?.photoURL?.absoluteString != nil{
            imgURL = firUser!.photoURL!.absoluteString
        } else {
            imgURL = ""
        }
        UserService.create(firUser!, name: name, location: location, imgURL: imgURL) { (user) in
            guard let user = user else { return }
            
            User.setCurrent(user, writeToUserDefaults: true)
            
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    func checkForLocationServices() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .denied, .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locations.last!, completionHandler: { (placemarks, error) in
            let placemark =  placemarks?[0]
            self.location = ""
            if let city = placemark?.locality {
                self.location.append(city + ", ")
            }
            if let state = placemark?.administrativeArea {
                self.location.append(state)
            }
            self.locationTextField.text = self.location
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
