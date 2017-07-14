//
//  PreviewEventViewController.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit

class PreviewEventViewController: UIViewController {
    
    var event: Event?
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let event = event {
            titleLabel.text = event.title
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateLabel.text = dateFormatter.string(from: event.date)
            locationLabel.text = event.location
            linkLabel.text = event.link
            descriptionLabel.text = event.description
            nameLabel.text = "\(event.creator.name) is going!"
            let imgURL = URL(string: event.imgURL)
            eventImageView.kf.setImage(with: imgURL)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
