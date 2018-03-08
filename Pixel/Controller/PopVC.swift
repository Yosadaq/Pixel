//
//  PopVC.swift
//  Pixel
//
//  Created by Yosadaq Esparza on 3/2/18.
//  Copyright © 2018 Y.M. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    
    var passedImage: UIImage!
    
    func initData(forImage image: UIImage) {
        self.passedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
popImageView.image = passedImage
        addDoubleTap()  
        
    }
     func addDoubleTap() {
        let doubletap = UITapGestureRecognizer(target: self, action: #selector(screenwasdoubletapped))
        doubletap.numberOfTapsRequired = 2
        doubletap.delegate = self
        view.addGestureRecognizer(doubletap)
    }
    @objc func screenwasdoubletapped() {
        dismiss(animated: true, completion: nil)
    }
}
