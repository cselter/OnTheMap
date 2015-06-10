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
     
     func getStudentLocationData() {
          
          let parseDataClient = OTMclient.sharedInstance()
          
          parseDataClient.getStudentLocations() {
               students, errorString in
               
               if let students = students {
                    println(students)
                    
                    if let appDelegate = self.appDelegate {
                         var studentDataArr: [Student] = [Student]()
                         
                         for studentResults in students {
                              studentDataArr.append(Student(studentData: studentResults))
                         }
                    }
                    
               } else {
                    if let error = errorString {
                         println(error)
                    }
               }
          }
     }
     
     
}