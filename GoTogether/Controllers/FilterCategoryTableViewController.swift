//
//  FilterViewController.swift
//  GoTogether
//
//  Created by Marta on 26/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit

class FilterCategoryTableViewController: UITableViewController {
    
    var selected = -1
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for row in 0 ..< tableView.numberOfRows(inSection: 0) {
            tableView.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryType = .none
        }
        
        if indexPath.row == selected {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            selected = -1
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selected = indexPath.row
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.layer.cornerRadius = 5
        tableView.layer.borderColor = UIColor.gtBlue.cgColor
        tableView.layer.borderWidth = 1
    }
    
}
