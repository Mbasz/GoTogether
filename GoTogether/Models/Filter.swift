//
//  Filter.swift
//  GoTogether
//
//  Created by Marta on 26/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation

class Filter {
    var isPublic: Bool
    var location: String
    var category: Int
    var date: Int
    var set: Bool
    
    init(isPublic: Bool, location: String, category: Int, date: Int) {
        self.isPublic = isPublic
        self.location = location
        self.category = category
        self.date = date
        self.set = false
    }
}
