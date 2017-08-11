//
//  GTPhotoHelper.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import UIKit

class GTImageHelper: NSObject {
    var completionHandler: ((UIImage) -> Void)?

    func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        viewController.addChildViewController(imagePickerController)
        viewController.navigationController?.setNavigationBarHidden(true, animated: false)
        imagePickerController.navigationBar.barTintColor = UIColor.gtPink
        imagePickerController.didMove(toParentViewController: viewController)
        viewController.view.addSubview(imagePickerController.view)
    }
}

extension GTImageHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            completionHandler?(selectedImage)
        }
        picker.view.removeFromSuperview()
        picker.removeFromParentViewController()
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.view.removeFromSuperview()
        picker.removeFromParentViewController()
        completionHandler?(UIImage(named: "uploadImage")!)
    }

}
