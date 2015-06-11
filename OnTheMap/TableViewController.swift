//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/7/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
     
     
     var appDelegate: AppDelegate!
     
     override func viewDidAppear(animated: Bool) {
          var studentDataArray = appDelegate.allStudents
          println("Table")
          println(studentDataArray)
     }
     
     
}

