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
     @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
     
     var mapString: String?
     var geolocation: CLPlacemark!
     var latCL:CLLocationDegrees?
     var longCL:CLLocationDegrees?
     var blurEffectView: UIVisualEffectView!
          
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
          self.latCL = geolocation.location.coordinate.latitude
          self.longCL = geolocation.location.coordinate.longitude
          
          let mapPin = CLLocationCoordinate2DMake(latCL!, longCL!)
          
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
               invalidAddress.title = "Missing URL"
               invalidAddress.message = "Please enter a URL."
               invalidAddress.addButtonWithTitle("OK")
               invalidAddress.show()
          } else {
               blurActivityView()
               activityIndicator.startAnimating()
               
               if mediaURLtextField.text.lowercaseString.hasPrefix("http://") || mediaURLtextField.text.lowercaseString.hasPrefix("https://") {
                    finalURL = mediaURLtextField.text
                    } else {
                    finalURL = "http://\(mediaURLtextField.text)"
                    }

               let udacityClient = OTMclient()
               var appDelegate:AppDelegate!
               appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
               
               udacityClient.postStudentLocation(finalURL!, lat: latCL!, long: longCL!, mapString: finalURL!) { success in

                    if let success = success {
                         if success {
                              canBeDismissed = true
                              
                              let updateLat = self.geolocation.location.coordinate.latitude as Double
                              
                              let updateLong = self.geolocation.location.coordinate.longitude as Double
                              
                              appDelegate.loggedInStudent?.latitude = updateLat
                              appDelegate.loggedInStudent?.longitude = updateLong
                              appDelegate.loggedInStudent?.mediaURL = finalURL
                              
                              
                         } else {
                              println("unsuccessful post")
                              var failedPostAlert = UIAlertController(title: "Unable to Post", message: "Retry?", preferredStyle: UIAlertControllerStyle.Alert)
                              
                              failedPostAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                              }))
                              
                              failedPostAlert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                                   self.submitButtonTouchUp(self)
                              }))

                              
                              
                              self.presentViewController(failedPostAlert, animated: true, completion: nil)

                         }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                         if canBeDismissed == true {
                              self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                         }
                    }
               }
          }
          removeBlur()
          activityIndicator.stopAnimating()
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
     
     // ***********************************
     // * Blur Activity View During Login *
     // ***********************************
     func blurActivityView() {
          let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
          blurEffectView = UIVisualEffectView(effect: blurEffect)
          blurEffectView.frame = view.bounds
          blurEffectView.alpha = 0.5
          view.addSubview(blurEffectView)
     }
     
     func removeBlur() {
          dispatch_async(dispatch_get_main_queue(), {
               if self.blurEffectView != nil {
                    self.blurEffectView.removeFromSuperview()
               }
          })
     }
}