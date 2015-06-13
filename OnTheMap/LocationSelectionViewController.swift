//
//  LocationSelectionViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/11/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationSelectionViewController: UIViewController, UITextFieldDelegate {
     
     @IBOutlet weak var findOnTheMapButton: UIButton!
     @IBOutlet weak var cancelButton: UIButton!
     @IBOutlet weak var locationTextField: UITextField!

     override func viewDidLoad() {
          findOnTheMapButton.layer.cornerRadius = 5
          findOnTheMapButton.layer.borderWidth = 1
          findOnTheMapButton.layer.borderColor = UIColor.grayColor().CGColor
          findOnTheMapButton.backgroundColor = UIColor.whiteColor()
          locationTextField.backgroundColor = UIColor.clearColor()
          locationTextField.delegate = self
     }
     
     // **************************
     // * Returns to previous VC *
     // **************************
     @IBAction func cancelButtonTouchUp(sender: AnyObject) {
          self.dismissViewControllerAnimated(true, completion: nil)
     }
   
     // *************************************************************
     // * Locates address entered and sends to URLMapViewController *
     // *************************************************************
     @IBAction func findOnMapButtonTouchUp(sender: AnyObject) {
          
          let address = locationTextField.text as String
          var geocoder = CLGeocoder()
          
          geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
               if let placemark = placemarks?[0] as? CLPlacemark {
                    
                    let mediaURLViewController = self.storyboard?.instantiateViewControllerWithIdentifier("URLMapViewController") as! URLMapViewController
                    
                    // send over the placemark
                    mediaURLViewController.geolocation = placemark
                    mediaURLViewController.mapString = address
                    
                    self.presentViewController(mediaURLViewController, animated: true, completion: nil)
                    
               } else {
                    // Unable to identify location, ask user to re-enter
                    var invalidAddress = UIAlertView()
                    invalidAddress.title = "Invalid Location"
                    invalidAddress.message = "Unable to identify location. Please re-enter."
                    invalidAddress.addButtonWithTitle("OK")
                    invalidAddress.show()
               }
          })
     }
     
     // **********************************************************
     // * Dismiss keyboard if tap is registered outside of field *
     // **********************************************************
     override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
          locationTextField.resignFirstResponder()
     }
     
     // ******************************************
     // * Dismiss keyboard if return key pressed *
     // ******************************************
     func textFieldShouldReturn(textField: UITextField) -> Bool {
          if locationTextField.isFirstResponder() {
               locationTextField.resignFirstResponder()
          }
          return true
     }
}