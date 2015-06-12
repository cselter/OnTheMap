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
     
     @IBAction func editLocationButtonTouchUp(sender: AnyObject) {
          self.dismissViewControllerAnimated(true, completion: nil)
     }
     
     @IBAction func cancelButtonTouchUp(sender: AnyObject) {
          self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
     }
     
     @IBAction func submitButtonTouchUp(sender: AnyObject) {
          
          var finalURL: String?
          
          if mediaURLtextField.text.lowercaseString.hasPrefix("http://") || mediaURLtextField.text.lowercaseString.hasPrefix("https://") {
               finalURL = mediaURLtextField.text
          } else {
               finalURL = "http://\(mediaURLtextField.text)"
          }
          println(lat)
          println(long)
          // postStudentLocation(finalURL!)
     }
     
          

}