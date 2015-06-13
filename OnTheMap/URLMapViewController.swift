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
          
               udacityClient.postStudentLocation(false, enteredURL: finalURL!, lat: lat!, long: long!, mapString: finalURL!) { postsExist, success in
                    // TODO: CHANGE THIS SO IT CHECKS WHEN USER CLICKS POST PIN 
                    // TODO: SEPARATE OUT QUERY FROM POST IN OTM CLIENT!!!!!
                    
                    
                    if let postsExist = postsExist {
                         if postsExist == true {
                              // ALERT!
                              var alert = UIAlertController(title: "Post Exists", message: "You've already posted your location.", preferredStyle: UIAlertControllerStyle.Alert)
                              alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                              self.presentViewController(alert, animated: true, completion: nil)
                              
                              alert.addAction(UIAlertAction(title: "Delete & Post New", style: .Default, handler: { action in
                                   switch action.style{
                                   case .Default:
                                        println("default")
                                        // call postStudentLocation again with overwrite = true
                                        udacityClient.postStudentLocation(true, enteredURL: finalURL!, lat: self.lat!, long: self.long!, mapString: finalURL!) {
                                             postsExist, success in
                                             if success != nil {
                                                  if success == true {
                                                       canBeDismissed = true
                                                  } else {
                                                       println("after alert, not successful")
                                                  }
                                             }
                                        }
                                   case .Cancel:
                                        println("cancel")
                                        // dismiss and go back to map/table
                                        canBeDismissed = true
                                   case .Destructive:
                                        println("destructive")
                                   }
                              }))
                         }
                    }
                    
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