//
//  UIStoryboard+Utility.swift
//  GoTogether
//
//  Created by Marta on 11/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    enum GTType: String {
        case main
        case login
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    convenience init(type: GTType, bundle: Bundle? = nil){
        self.init(name: type.filename, bundle: bundle)
    }
    
    static func initialViewController(for type: GTType) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Couldn't instantiate initial view controller for\(type.filename) storyboard.")
        }
        
        return initialViewController
    }
    
}
