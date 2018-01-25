//
//  PopVC.swift
//  pixel-city
//
//  Created by ahmed on 1/25/18.
//  Copyright © 2018 ahmed. All rights reserved.
//

import UIKit

class PopVC: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
  
    var passedImage :UIImage!
    
    func initData(forImage image:UIImage)
    {
    self.passedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        addDoubleTab()
        // Do any additional setup after loading the view.
    }

    func addDoubleTab(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenTapped) )
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenTapped()  {
        dismiss(animated: true, completion: nil)
    }

}
