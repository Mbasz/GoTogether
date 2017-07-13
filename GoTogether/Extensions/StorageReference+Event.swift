//
//  StorageReference+Event.swift
//  GoTogether
//
//  Created by Marta on 12/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import FirebaseStorage

extension StorageReference {
    static let dateFormatter = ISO8601DateFormatter()
    
    static func newEventImageReference() -> StorageReference {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/events/\(uid)\(timestamp).jpg")
    }
}
