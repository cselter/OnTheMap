//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/7/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
     
     
     var appDelegate: AppDelegate!
     
     var studentList: [Student]?
     
     @IBOutlet var tableView: UITableView!
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
          
          studentList = appDelegate?.allStudents
     }
     
     
     override func viewDidAppear(animated: Bool) {
          
          // give alert to user if no pins are loaded
          if studentList!.count == 0
          {
               var emptyMemesAlert = UIAlertView()
               emptyMemesAlert.title = "No Pins"
               emptyMemesAlert.message = "There are no pins. Please refresh!"
               emptyMemesAlert.addButtonWithTitle("OK")
               emptyMemesAlert.show()
          }
     }

     
     
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return studentList!.count
     }
     
     // Return cell for each grid row
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCellWithIdentifier("StudentTableCell", forIndexPath: indexPath) as! UITableViewCell
          let studentCell = studentList![indexPath.row]
          cell.imageView?.image = UIImage(named:  "pin")
          cell.textLabel?.text = "\(studentCell.firstName!) \(studentCell.lastName!)"
          cell.detailTextLabel?.text = studentCell.mediaURL
          
          return cell
     }
     
     // Show Detail View when row is selected
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
          
          
     }

     
     
     
     
     
}

