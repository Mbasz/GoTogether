//
//  Event.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation

enum Category {
    case sport, culture, workshop
}

class Event {
    let creator = User()
    var title = ""
    var date = Date()
    var description = ""
    var going: User? = nil
    var category = Category.culture
    
}
