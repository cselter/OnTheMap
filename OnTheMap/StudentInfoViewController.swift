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
 
     
     var appDelegate: AppDelegate!
     var userfName: String?
     var userlName: String?
     var userKey: String?
     var lat: CLLocationDegrees?
     var long: CLLocationDegrees?
     var loc: CLPlacemark?
     var url: String?
     
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
     

          
          
          // Update the labels
          nameLabel.text = userfName! + " " + userlName!
          studentKey.text = self.userKey
          
          
          
     }
     
     
     
     
     
}

