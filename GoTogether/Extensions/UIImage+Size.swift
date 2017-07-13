//
//  UIImage+Size.swift
//  GoTogether
//
//  Created by Marta on 12/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var aspectHeight: CGFloat {
        let heightRatio = size.height / 736
        let widthRatio = size.width / 414
        let aspectRatio = fmax(heightRatio, widthRatio)
        
        return size.height / aspectRatio
    }
    
}
