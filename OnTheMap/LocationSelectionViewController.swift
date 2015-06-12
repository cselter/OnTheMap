//
//  LocationSelectionViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/11/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit

class LocationSelectionViewController: UIViewController {
     
     @IBOutlet weak var findOnTheMapButton: UIButton!
     
     @IBOutlet weak var locationTextView: UITextView!
     @IBOutlet weak var cancelButton: UIButton!
     
     override func viewDidLoad() {
          findOnTheMapButton.layer.cornerRadius = 5
          findOnTheMapButton.layer.borderWidth = 1
          findOnTheMapButton.layer.borderColor = UIColor.grayColor().CGColor
          findOnTheMapButton.backgroundColor = UIColor.whiteColor()
          locationTextView.backgroundColor = UIColor.clearColor()
     }
     
     
     
     @IBAction func cancelButtonTouchUp(sender: AnyObject) {
          self.dismissViewControllerAnimated(true, completion: nil)
     }
     
}