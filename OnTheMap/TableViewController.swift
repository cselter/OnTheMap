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
     @IBOutlet weak var refreshButton: UIBarButtonItem!
     @IBOutlet weak var locationButton: UIBarButtonItem!
     @IBOutlet weak var logoutButton: UIBarButtonItem!
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
          
          studentList = appDelegate?.allStudents
          
          tableView.delegate = self
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
     
     // Open URL in Safari when row is selected
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
          
          println("row selected")
          dispatch_async(dispatch_get_main_queue()) {
               if let mediaURL = self.studentList![indexPath.row].mediaURL {
                    println("\(mediaURL)")

                   
                    
                    
                    
                    
                    
                    if mediaURL.lowercaseString.hasPrefix("http://") || mediaURL.lowercaseString.hasPrefix("https://"){
                         
                         if let url = NSURL(string: mediaURL) {

                              println("url saved")
                              UIApplication.sharedApplication().openURL(url)

                         }
                    } else {
                         let updatedURL = "http://\(mediaURL)"
                         
                         if let url = NSURL(string: updatedURL) {
                              println("fixed URL")
                              UIApplication.sharedApplication().openURL(url)
                         }
                    }
                    
                    

                              }
          }
     }

     
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
                    }
               } else {
                    if let error = errorString {
                         println(error)
                    }
               }
          }
          
          self.tableView.reloadData()
     }
     
     
     
     
}

