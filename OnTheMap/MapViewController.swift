//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/7/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

     @IBOutlet weak var mapView: MKMapView!
     @IBOutlet weak var logoutButton: UIBarButtonItem!
     @IBOutlet weak var locationButton: UIBarButtonItem!
     @IBOutlet weak var refreshButton: UIBarButtonItem!
     @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
     
     var appDelegate: AppDelegate!
     var userKey: String?
     var mapPins = [MKAnnotation]()
     var blurEffectView: UIVisualEffectView!
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
          userKey = appDelegate.loggedInStudent?.studentKey
          mapView.delegate = self
          
          blurActivityView()
          activityIndicator.startAnimating()
          
          getStudentLocationData()
     }
     
     override func viewDidAppear(animated: Bool) {
          super.viewDidAppear(true)
          
          getStudentLocationData()
          addStudentMapPins()
          defaultZoom()
          
          removeBlur()
          activityIndicator.stopAnimating()
     }

     // *********************************
     // * Zoom Out & Pan back to the US *
     // *********************************
     func defaultZoom(){
          var latOut: Double = 37.13284
          var longOut: Double = -95.78558
          let zoomOut = CLLocationCoordinate2DMake(latOut, longOut)
          var zoomOutView = MKMapCamera(lookingAtCenterCoordinate: zoomOut, fromEyeCoordinate: zoomOut, eyeAltitude: 18000000.0)
          self.mapView.setCamera(zoomOutView, animated: true)
     }
     
     // ********************************************
     // * Get Student Location Data from Parse API *
     // ********************************************
     func getStudentLocationData() {
          
          let parseDataClient = OTMclient.sharedInstance()
          
          parseDataClient.getStudentLocations() {
               students, errorString in
               
               if let students = students {
                    
                    if let appDelegate = self.appDelegate {
                         var studentDataArr: [Student] = [Student]()
                         
                         for studentResults in students {
                              studentDataArr.append(Student(studentData: studentResults))
                         }
                         appDelegate.allStudents = studentDataArr
                         
                         self.addStudentMapPins()
                    }
               } else {
                    if let error = errorString {
                         println(error)
                    }
               }
          }
     }
     
     // **********************************************
     // * Add Pins to Map with Student Location Data *
     // **********************************************
     func addStudentMapPins() {
          dispatch_async(dispatch_get_main_queue()) {
               if let studentMapPins = self.appDelegate?.allStudents {
                    if studentMapPins.count > 0 {
                         if self.mapView.annotations.count > 0 {
                              // if pins already exist, clear them out before loading new ones
                              self.mapView.removeAnnotations(self.mapView.annotations)
                              self.mapPins.removeAll(keepCapacity: false)
                         }
                         
                         for students in studentMapPins {
                              // ensure all data is present before loading pin
                              if let long = students.longitude {
                                   if let lat = students.latitude {
                                        if let fName = students.firstName {
                                             if let lName = students.lastName {
                                                  if let studentURL = students.mediaURL {
                                                       let lat = CLLocationDegrees(Double((lat)))
                                                       let long = CLLocationDegrees(Double((long)))
                                                       let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                                       var mapPin = MKPointAnnotation()
                                                       mapPin.coordinate = coordinate
                                                       mapPin.title = "\(fName) \(lName)"
                                                       mapPin.subtitle = studentURL
                                                       
                                                       self.mapPins.append(mapPin)
                                                  }
                                             }
                                        }
                                   }
                              }
                              
                              if self.mapPins.count == 0 {
                                   println("No pins in the array")
                              } else {
                                   self.mapView.addAnnotations(self.mapPins)
                              }
                         }
                    } else {
                         println("No student data in appDelegate")
                         
                         var failedPostAlert = UIAlertController(title: "No Student Data", message: "Retry?", preferredStyle: UIAlertControllerStyle.Alert)
                         
                         failedPostAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                         }))
                         
                         failedPostAlert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                              self.reloadButtonTouchUp(self)
                         }))
                         
                         self.presentViewController(failedPostAlert, animated: true, completion: nil)
                    }
               }
          }
     }
     
     // ***********************************************
     // * Get fresh data from API and reload map pins *
     // ***********************************************
     @IBAction func reloadButtonTouchUp(sender: AnyObject) {
          activityIndicator.startAnimating()
          getStudentLocationData()
          addStudentMapPins()
          activityIndicator.stopAnimating()
     }
     
     // *************************************************
     // * Configure annotation view of the student Pins *
     // *************************************************
     func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
          
          var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("studentPin") as? MKPinAnnotationView
          
          if pinView == nil {
               pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "studentPin")
               pinView?.canShowCallout = true
               pinView?.pinColor = .Red
               pinView?.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
          } else {
               pinView?.annotation = annotation
          }
          
          return pinView
     }
     
     // **************************************
     // * Open URL when annotation is tapped *
     // **************************************
     func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
          if control == view.rightCalloutAccessoryView {
               
               if let mediaURL = view.annotation.subtitle! {
                    
                    if mediaURL.lowercaseString.hasPrefix("http://") || mediaURL.lowercaseString.hasPrefix("https://"){
                    
                         if let url = NSURL(string: mediaURL) {
                              UIApplication.sharedApplication().openURL(url)
                         }
                    } else {
                         let updatedURL = "http://\(mediaURL)"
                    
                         if let url = NSURL(string: updatedURL) {
                              UIApplication.sharedApplication().openURL(url)
                         }
                    }
               }
          }
     }
     
     // ****************************************************
     // * Post new student location, checking for existing *
     // ****************************************************
     @IBAction func locationButtonTouchUp(sender: AnyObject) {
          let client = OTMclient.sharedInstance()
          client.queryForStudentLocation() {
               data, error in
               
               if error == nil { // if no error
                    if let data = data { // and data is not nil
                         if data.count > 0 { // and count of objects is >0
                              // existing posts found
                              // zoom to existing pin
                              var lat: Double = data[0]["latitude"] as! Double
                              var long: Double = data[0]["longitude"] as! Double
                              
                              var latCord: CLLocationDegrees = lat
                              var longCord: CLLocationDegrees = long

                              let existingLoc = CLLocationCoordinate2DMake(latCord, longCord)
                              var zoomView = MKMapCamera(lookingAtCenterCoordinate: existingLoc, fromEyeCoordinate: existingLoc, eyeAltitude: 10000.0)
                              self.mapView.setCamera(zoomView, animated: true)
                              
                              // Show annotation view of pin after zoomed in
                              // * Couldn't get this to work *
                              // Desired action: after map zooms in to existing pin, have the annotation view (pop up with name and url) automatically show.
                              // Since I have an ActivitySheet for my alert, the user can't click on it without dismissing the alert.
                              // If you know of a way to do this, I would love to learn!
                              /*
                                   let anns = self.mapView.annotationsInMapRect(self.mapView.visibleMapRect) as? MKAnnotation
                                   
                                   self.mapView.selectAnnotation(self.mapPins[0], animated: true)
                                   
                                   self.mapView.selectAnnotation(self.mapView.annotations as? MKAnnotation, animated: true)
                              */
                              
                              // alert the user of the existing location pin
                              var alert = UIAlertController(title: "Existing Pin", message: "You've already posted your location.", preferredStyle: UIAlertControllerStyle.ActionSheet)
                              
                              alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                                   self.defaultZoom()
                              }))

                              alert.addAction(UIAlertAction(title: "Delete & Post New", style: .Default, handler: { action in
                                   client.deleteExistingPosts(data)
                                   // Segue to Location Entry
                                   self.performSegueWithIdentifier("OpenLocationSelectVC", sender: self)
                              }))
                              
                              self.presentViewController(alert, animated: true, completion: nil)
                              
                         } else {
                              self.performSegueWithIdentifier("OpenLocationSelectVC", sender: self)
                         }
                    }
               } else {
                    var downloadFailureAlert = UIAlertController(title: "Query Failed", message: "Unable to download student locations.", preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(downloadFailureAlert, animated: true, completion: nil)
                    println("unable to query existing posts")
               }
          }
     }
     
     // *****************************************************
     // * Log out of Udacity Session and Return to Login VC *
     // *****************************************************
     @IBAction func logoutButtonTouchUp(sender: AnyObject) {
          let openSession = OTMclient.sharedInstance()
          openSession.logoutOfUdacity()
          self.dismissViewControllerAnimated(true, completion: nil)
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