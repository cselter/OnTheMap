//
//  StudentInfoViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/6/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StudentInfoViewController: UIViewController {
     
     @IBOutlet weak var nameLabel: UILabel!
     @IBOutlet weak var studentKey: UILabel!
     @IBOutlet weak var mediaURLLabel: UILabel!
     @IBOutlet weak var latLabel: UILabel!
     @IBOutlet weak var longLabel: UILabel!
     @IBOutlet weak var mapView: MKMapView!
 
     
     var appDelegate: AppDelegate!
     var userfName: String?
     var userlName: String?
     var userKey: String?
     var lat: Double?
     var long: Double?
     var loc: CLPlacemark?
     var mediaURL: String?
     
     override func viewDidLoad() {
          super.viewDidLoad()
          appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
     }
     
     override func viewDidAppear(animated: Bool) {
          // Refreshes this page each time it is viewed with current info
          // from the appDelegate
          
          if let userName = appDelegate.loggedInStudent?.firstName {
               userfName = userName
          } else {
               userfName = "unavail"
          }
          
          if let userName = appDelegate.loggedInStudent?.lastName {
               userlName = userName
          } else {
               userlName = "unavail"
          }
          
          if let key = appDelegate.loggedInStudent?.studentKey {
               userKey = key
          } else {
               userKey = "unavail"
          }
     
          if let url = appDelegate.loggedInStudent?.mediaURL {
               mediaURL = url
          } else {
               mediaURL = "not posted yet"
          }
          
          if let latLoc = appDelegate.loggedInStudent?.latitude {
               lat = latLoc
          } else {
               lat = nil
          }
          if let longLoc = appDelegate.loggedInStudent?.longitude {
               long = longLoc
          } else {
               long = nil
          }
          
          
          // Update the labels
          nameLabel.text = userfName! + " " + userlName!
          studentKey.text = self.userKey
          mediaURLLabel.text = self.mediaURL
          
          if lat != nil {
               latLabel.text = String(stringInterpolationSegment: self.lat!)
          } else {
               latLabel.text = "not posted yet"
          }
          
          if long != nil {
               longLabel.text = String(stringInterpolationSegment: self.long!)
          } else {
               longLabel.text = "not posted yet"
          }
          
     }
     
     
     
     
     
}

