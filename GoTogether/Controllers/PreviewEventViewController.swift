//
//  PreviewEventViewController.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import FacebookShare
import FacebookCore
import BEMCheckBox

class PreviewEventViewController: UIViewController, BEMCheckBoxDelegate {
    
    var event: Event?
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var checkboxLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkbox.delegate = self
        if let event = event {
            titleLabel.text = event.title
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateLabel.text = dateFormatter.string(from: event.date)
            dateFormatter.timeStyle = .medium
            dateFormatter.dateFormat = "hh:mm a"
            timeLabel.text = event.time
            locationLabel.text = event.location
            descriptionLabel.text = event.description
            nameLabel.text = "\(event.creator.name) is going!"
            let eventImgURL = URL(string: event.imgURL)
            let profileImgURL = URL(string: event.creator.imgURL)
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.cornerRadius = profileImageView.frame.height/2
            eventImageView.kf.setImage(with: eventImgURL)
            profileImageView.kf.setImage(with: profileImgURL)
            
            let shareButton = ShareButton<LinkShareContent>()
            if let url = URL(string: event.link) {
                let content = LinkShareContent(url: url)
                shareButton.content = content
            }
            shareButton.frame.origin.y = 550
            shareButton.frame.size = CGSize(width: 70, height: 30)
            shareButton.center.x = self.view.center.x + 140
//            let shareDialog = ShareDialog(content: content)
//            shareDialog.mode = .native
            self.view.addSubview(shareButton)
            checkbox.onAnimationType = .bounce
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animationDidStop(for checkBox: BEMCheckBox) {
        if checkbox.on {
            checkbox.isHidden = true
            nameLabel.text = "You're going with \(event!.creator.name)!"
            checkboxLabel.text = ""
        }
    }
    
    @IBAction func linkButtonTapped(_ sender: Any) {
        if let event = event, let urlLink = URL(string: event.link) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(urlLink, options: [:], completionHandler:  { success in
                    if !success {
                        let alertController = UIAlertController(title: "Invalid URL", message: nil, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            } else {
                UIApplication.shared.openURL(urlLink)
            }
        }
        else {
            let alertController = UIAlertController(title: "Invalid URL", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

