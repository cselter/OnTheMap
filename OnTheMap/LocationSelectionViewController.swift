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
   
     
     @IBAction func findOnMapButtonTouchUp(sender: AnyObject) {
          
          let address = locationTextView.text as String
          var geocoder = CLGeocoder()
          
          geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
               if let placemark = placemarks?[0] as? CLPlacemark {
                    
                    let mediaURLViewController = self.storyboard?.instantiateViewControllerWithIdentifier("URLMapViewController") as! URLMapViewController
                    
                    // send over the placemark
                    mediaURLViewController.geolocation = placemark
                    
                    self.presentViewController(mediaURLViewController, animated: true, completion: nil)
                    
               } else {
                    // TODO: alert the user
                    
                    
                    
               }
          })
     }
}