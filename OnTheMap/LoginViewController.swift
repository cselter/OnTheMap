//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/4/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

     @IBOutlet weak var usernameTextField: UITextField!
     @IBOutlet weak var passwordTextField: UITextField!
     @IBOutlet weak var loginButton: UIButton!
     @IBOutlet weak var debugTextLabel: UILabel!
     
     var appDelegate: AppDelegate!
     var session: NSURLSession!
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          usernameTextField.delegate = self
          passwordTextField.delegate = self
          
          // Get the app delegate
          appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
          
          // Get the shared URL session
          session = NSURLSession.sharedSession()
     }
     
     override func viewDidAppear(animated: Bool) {
          super.viewWillAppear(animated)
          self.debugTextLabel.text = ""
     }
     
     func textFieldShouldReturn(textField: UITextField) -> Bool {
          if usernameTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
               usernameTextField.resignFirstResponder()
               passwordTextField.resignFirstResponder()
          }
          return true
     }
     
     override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
          usernameTextField.resignFirstResponder()
          passwordTextField.resignFirstResponder()
     }
     
     @IBAction func loginButtonTouchUp(sender: AnyObject) {
          let udacityClient = OTMclient()
          
          udacityClient.loginToUdacity(usernameTextField.text, password: passwordTextField.text){
               success, data, error in
               
               if success {
                    println("YAY!")
                    
                    // update loggedInStudent with returned data (studentKey)
                    self.appDelegate.loggedInStudent = Student(studentData: data)
                    
                    // get student data for loggedInStudent
                    self.getStudentData(udacityClient)
                    
                    // transition to tab controller
                    self.completeLogin()
               }
               else {
                    println("Login Error")
                    println(error)
                    
                    // shake the screen
                    dispatch_async(dispatch_get_main_queue(), {
                         self.loginFailShake()
                    })

                    // TODO: parse error to provide friendly debug lable code
                    self.displayError(error)
               }
          }
     }
     
     
     // Get Student Data from Udacity
     func getStudentData(udacityClient: OTMclient) {

          let key = appDelegate.loggedInStudent?.studentKey
          
          udacityClient.getUdacityStudentData(key!){
               data, errorString in
               
               
          }
          
          
          
     }
     
     
     
     
     
     // Login Successful, Move to Tab Bar Controller
     func completeLogin() {
          dispatch_async(dispatch_get_main_queue(), {
               self.debugTextLabel.text = "Login Success!"
               let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
               
               self.presentViewController(controller, animated: true, completion: nil)
          })
     }
     
     // Update Error Label with Message
     func displayError(errorString: String?) {
          dispatch_async(dispatch_get_main_queue(), {
               if let errorString = errorString {
                    self.debugTextLabel.text = errorString
               }
          })
     }
     
     // Open Udacity Sign Up Page
     @IBAction func signUpButton(sender: AnyObject) {
          if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
               UIApplication.sharedApplication().openURL(url)
          }
     }
     
     // Shake the screen if login failure
     func loginFailShake() {
          let anim = CAKeyframeAnimation( keyPath:"transform" )
          anim.values = [
               NSValue( CATransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
               NSValue( CATransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )
          ]
          anim.autoreverses = true
          anim.repeatCount = 2
          anim.duration = 7/100
          
          self.view.layer.addAnimation(anim, forKey: nil)
     }
}