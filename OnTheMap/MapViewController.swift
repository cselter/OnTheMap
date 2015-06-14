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
     
     var appDelegate: AppDelegate!
     var userKey: String?
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
          userKey = appDelegate.loggedInStudent?.studentKey
          mapView.delegate = self
          // TODO: disables interactions so data can load... change to loading screen?
          UIApplication.sharedApplication().beginIgnoringInteractionEvents()
          getStudentLocationData()
          UIApplication.sharedApplication().endIgnoringInteractionEvents()
     }
     
     override func viewDidAppear(animated: Bool) {
          super.viewDidAppear(true)
          addStudentMapPins()
          // TODO: ACTIVITY VIEW?

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
                         }
                         
                         var mapPins = [MKAnnotation]()
                         
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
                                                       
                                                       mapPins.append(mapPin)
                                                  }
                                             }
                                        }
                                   }
                              }
                              
                              if mapPins.count == 0 {
                                   println("No pins in the array")
                              } else {
                                   self.mapView.addAnnotations(mapPins)
                              }
                         }
                    } else {
                         println("No student data in appDelegate")
                    }
               }
          }
     }
     
     // ***********************************************
     // * Get fresh data from API and reload map pins *
     // ***********************************************
     @IBAction func reloadButtonTouchUp(sender: AnyObject) {
          getStudentLocationData()
          addStudentMapPins()
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
                              // existing posts found, alert user
                              // TODO: ZOOM TO LOCATION
                              var alert = UIAlertController(title: "Existing Pin", message: "You've already posted your location.", preferredStyle: UIAlertControllerStyle.Alert)
                              alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                              self.presentViewController(alert, animated: true, completion: nil)
                              alert.addAction(UIAlertAction(title: "Delete & Post New", style: .Default, handler: { action in
                                   switch action.style{
                                   case .Default:
                                        println("default")
                                        client.deleteExistingPosts(data)
                                        // SEGUE TO LOCATION ENTRY
                                        self.performSegueWithIdentifier("OpenLocationSelectVC", sender: self)
                                   case .Cancel:
                                        println("cancel")
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                   case .Destructive:
                                        println("destructive")
                                   }
                              }))
                         } else {
                              self.performSegueWithIdentifier("OpenLocationSelectVC", sender: self)
                         }
                    }
               } else {
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
}