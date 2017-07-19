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

class CreateProfileViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var location = ""
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location = ""
        self.checkForLocationServices()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.requestLocation()
        }
        else {
            
        }
        
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        guard let firUser = Auth.auth().currentUser, let name = fullNameTextField.text, let location = locationTextField.text, !name.isEmpty, !location.isEmpty
            else { return }
        
        var imgURL = firUser.photoURL?.absoluteString
        if imgURL == nil {
            imgURL = "https://cdn.pixabay.com/photo/2017/06/13/12/54/profile-2398783_960_720.png"
        }
        UserService.create(firUser, name: name, location: location, imgURL: imgURL!) { (user) in
            guard let user = user else { return }
            
            User.setCurrent(user, writeToUserDefaults: true)
            
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
            
            print("Created new user \(user.name)")
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
