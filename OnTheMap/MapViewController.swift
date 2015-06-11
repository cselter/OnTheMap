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
     }
     
     override func viewDidAppear(animated: Bool) {
          getStudentLocationData()
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

}