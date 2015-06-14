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

class URLMapViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
     
     @IBOutlet weak var cancelButton: UIButton!
     @IBOutlet weak var submitButton: UIButton!
     @IBOutlet weak var mapView: MKMapView!
     @IBOutlet weak var mediaURLtextField: UITextField!
     
     var mapString: String?
     var geolocation: CLPlacemark!
     var lat:CLLocationDegrees?
     var long:CLLocationDegrees?
          
     override func viewDidLoad() {
          submitButton.layer.cornerRadius = 5
          submitButton.layer.borderWidth = 1
          submitButton.layer.borderColor = UIColor.grayColor().CGColor
          submitButton.backgroundColor = UIColor.whiteColor()
          mediaURLtextField.backgroundColor = UIColor.clearColor()
          
          mapView.delegate = self
          mediaURLtextField.delegate = self
     }
     
     override func viewDidAppear(animated: Bool) {
          self.mapView.addAnnotation(MKPlacemark(placemark: geolocation))
          self.lat = geolocation.location.coordinate.latitude
          self.long = geolocation.location.coordinate.longitude
          
          let mapPin = CLLocationCoordinate2DMake(lat!, long!)
          
          var zoomView =
          MKMapCamera(lookingAtCenterCoordinate: mapPin, fromEyeCoordinate: mapPin, eyeAltitude: 10000.0)
          self.mapView.setCamera(zoomView, animated: true)
     }
     
     // *************************************************
     // * Return to location selection screen to update *
     // *************************************************
     @IBAction func editLocationButtonTouchUp(sender: AnyObject) {
          self.dismissViewControllerAnimated(true, completion: nil)
     }
     
     // ***************************************************
     // * Return to original tabbed view (map/table view) *
     // ***************************************************
     @IBAction func cancelButtonTouchUp(sender: AnyObject) {
          self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
     }
     
     // ****************************************************
     // * Submit location and url to OTMclient for posting *
     // ****************************************************
     @IBAction func submitButtonTouchUp(sender: AnyObject) {
          var finalURL: String?
          var canBeDismissed: Bool = false
          
          if finalURL == "" {
               // Empty URL
               var invalidAddress = UIAlertView()
               invalidAddress.title = "Invalid URL"
               invalidAddress.message = "Please enter a URL."
               invalidAddress.addButtonWithTitle("OK")
               invalidAddress.show()
          } else {
               if mediaURLtextField.text.lowercaseString.hasPrefix("http://") || mediaURLtextField.text.lowercaseString.hasPrefix("https://") {
                    finalURL = mediaURLtextField.text
                    } else {
                    finalURL = "http://\(mediaURLtextField.text)"
                    }

               let udacityClient = OTMclient()
          
               udacityClient.postStudentLocation(finalURL!, lat: lat!, long: long!, mapString: finalURL!) { success in

                    if let success = success {
                         if success {
                              canBeDismissed = true
                         } else {
                              println("unsuccessful post")
                         }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                         if canBeDismissed == true {
                              self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                         }
                    }
               }
          }
     }
     
     // **********************************************************
     // * Dismiss keyboard if tap is registered outside of field *
     // **********************************************************
     override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
          mediaURLtextField.resignFirstResponder()
     }
     
     // ******************************************
     // * Dismiss keyboard if return key pressed *
     // ******************************************
     func textFieldShouldReturn(textField: UITextField) -> Bool {
          if mediaURLtextField.isFirstResponder() {
               mediaURLtextField.resignFirstResponder()
          }
          return true
     }
}