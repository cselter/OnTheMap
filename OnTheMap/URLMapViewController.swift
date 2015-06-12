//
//  URLMapViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/11/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class URLMapViewController: UIViewController, MKMapViewDelegate {
     
     
     @IBOutlet weak var cancelButton: UIButton!
     @IBOutlet weak var submitButton: UIButton!
     @IBOutlet weak var mapView: MKMapView!
     @IBOutlet weak var mediaURLtextField: UITextView!
     
     override func viewDidLoad() {
          
          submitButton.layer.cornerRadius = 5
          submitButton.layer.borderWidth = 1
          submitButton.layer.borderColor = UIColor.grayColor().CGColor
          submitButton.backgroundColor = UIColor.whiteColor()
          mediaURLtextField.backgroundColor = UIColor.clearColor()
     }
     
     
     @IBAction func editLocationButtonTouchUp(sender: AnyObject) {
          self.dismissViewControllerAnimated(true, completion: nil)
     }
     
     @IBAction func cancelButtonTouchUp(sender: AnyObject) {
          self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
     }
     
}