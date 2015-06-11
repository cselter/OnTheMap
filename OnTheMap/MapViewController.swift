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
          // TODO: Might not need
          
          // TODO: add overlay view that shows when loading to prevent user touching other views before they're ready
          
          // TODO: double check to make sure this is working correctly
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
     
               
               
               

     

     // TODO: IF NOT USED, REMOVE IT
     func showActivityIndicatory(uiView: UIView) {
          var container: UIView = UIView()
          container.frame = uiView.frame
          container.center = uiView.center
          container.backgroundColor = UIColor.blackColor()
     
          var loadingView: UIView = UIView()
          loadingView.frame = CGRectMake(0, 0, 80, 80)
          loadingView.center = uiView.center
          loadingView.backgroundColor = UIColor.whiteColor()
          loadingView.clipsToBounds = true
          loadingView.layer.cornerRadius = 10
          
          var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
          actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
          actInd.activityIndicatorViewStyle =
               UIActivityIndicatorViewStyle.WhiteLarge
          actInd.center = CGPointMake(loadingView.frame.size.width / 2,
               loadingView.frame.size.height / 2);
          loadingView.addSubview(actInd)
          container.addSubview(loadingView)
          uiView.addSubview(container)
          actInd.startAnimating()
     }
     
     
}