//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/7/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
     @IBOutlet var tableView: UITableView!
     @IBOutlet weak var refreshButton: UIBarButtonItem!
     @IBOutlet weak var locationButton: UIBarButtonItem!
     @IBOutlet weak var logoutButton: UIBarButtonItem!
     
     var appDelegate: AppDelegate!
     var studentList: [Student]?
     
     override func viewDidLoad() {
          super.viewDidLoad()
          appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
          studentList = appDelegate?.allStudents
          tableView.delegate = self
     }
     
     override func viewDidAppear(animated: Bool) {
          refreshButtonTouchUp(self)
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

     // ********************
     // * Table Cell Count *
     // ********************
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return studentList!.count
     }
     
     // *********************************
     // * Return cell for each grid row *
     // *********************************
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCellWithIdentifier("StudentTableCell", forIndexPath: indexPath) as! UITableViewCell
          let studentCell = studentList![indexPath.row]
          cell.imageView?.image = UIImage(named: "pin")
          cell.textLabel?.text = "\(studentCell.firstName!) \(studentCell.lastName!)"
          cell.detailTextLabel?.text = studentCell.mediaURL
          
          return cell
     }
     
     // *******************************************
     // * Open URL in Safari when row is selected *
     // *******************************************
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
          dispatch_async(dispatch_get_main_queue()) {
               if let mediaURL = self.studentList![indexPath.row].mediaURL {

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
     
     // *****************************************************
     // * Log out of Udacity Session and Return to Login VC *
     // *****************************************************
     @IBAction func logoutButtonTouchUp(sender: AnyObject) {
          let openSession = OTMclient.sharedInstance()
          openSession.logoutOfUdacity()
          self.dismissViewControllerAnimated(true, completion: nil)
     }
     
     // **************************
     // * Refresh the data model *
     // **************************
     @IBAction func refreshButtonTouchUp(sender: AnyObject) {
          let dataClient = OTMclient.sharedInstance()
          
          dataClient.getStudentLocations() {
               students, errorString in
               
               if let students = students {
                    
                    if let appDelegate = self.appDelegate {
                         var studentDataArr: [Student] = [Student]()
                         
                         for studentResults in students {
                              studentDataArr.append(Student(studentData: studentResults))
                         }
                         appDelegate.allStudents = studentDataArr
                         self.studentList = studentDataArr
                         self.reloadTableData()
                    }
               } else {
                    if let error = errorString {
                         println(error)
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
                              // alert the user of the existing location pin
                              var alert = UIAlertController(title: "Existing Pin", message: "You've already posted your location.", preferredStyle: UIAlertControllerStyle.ActionSheet)
                              
                              alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                              }))
                              
                              alert.addAction(UIAlertAction(title: "Delete & Post New", style: .Default, handler: { action in
                                   client.deleteExistingPosts(data)
                                   // Segue to Location Entry
                                   self.performSegueWithIdentifier("OpenLocationSelectVCfromTable", sender: self)
                              }))
                              self.presentViewController(alert, animated: true, completion: nil)
                         } else {
                              self.performSegueWithIdentifier("OpenLocationSelectVCfromTable", sender: self)
                         }
                    }
               } else {
                    println("unable to query existing posts")
               }
          }
     }
     
     // ******************************
     // * Reload the table cell data *
     // ******************************
     func reloadTableData() {
          dispatch_async(dispatch_get_main_queue()) {
               self.tableView.beginUpdates()
               self.tableView.reloadData()
               self.tableView.endUpdates()
          }
     }
}