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
     @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
     
     var appDelegate: AppDelegate!
     var session: NSURLSession!
     var blurEffectView: UIVisualEffectView!
     
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
          self.removeBlur()
          super.viewWillAppear(animated)
          self.debugTextLabel.text = ""
          
          // TODO: REMOVE THIS!!!!
          self.usernameTextField.text = "cdotburgess@gmail.com"
          self.passwordTextField.text = "9cj25h7a"
     }
     
     // ******************************************
     // * Dismiss keyboard if return key pressed *
     // ******************************************
     func textFieldShouldReturn(textField: UITextField) -> Bool {
          if usernameTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
               usernameTextField.resignFirstResponder()
               passwordTextField.resignFirstResponder()
          }
          return true
     }
     
     // **********************************************************
     // * Dismiss keyboard if tap is registered outside of field *
     // **********************************************************
     override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
          usernameTextField.resignFirstResponder()
          passwordTextField.resignFirstResponder()
     }
     
     // *********************************
     // * Initiate Login to Udacity API *
     // *********************************
     @IBAction func loginButtonTouchUp(sender: AnyObject) {
          
          activityIndicator.startAnimating()
          
          let udacityClient = OTMclient()
          debugTextLabel.text = ""
          blurActivityView()

          udacityClient.loginToUdacity(usernameTextField.text, password: passwordTextField.text){
               success, data, error in
               
               
               if success {
                    
                    
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
                    self.activityIndicator.stopAnimating()
                    self.removeBlur()
                    
                    let missingUserName = "trails.Error 400: Missing parameter \'username\'"
                    let missingPassword = "trails.Error 400: Missing parameter \'password\'"
                    
                    switch(error!) {
                         case (missingUserName):
                              self.displayError("Missing Username")
                         
                         case (missingPassword):
                              self.displayError("Missing Password")
                         
                         default:
                              self.displayError(error)
                    }
               }
          }
     }
     
     // *********************************
     // * Get Student Data from Udacity *
     // *********************************
     func getStudentData(udacityClient: OTMclient) {

          let key = appDelegate.loggedInStudent?.studentKey
          
          udacityClient.getUdacityStudentData(key!){
               data, errorString in
               
               if let studentData = data {
                    dispatch_async(dispatch_get_main_queue()) {
                         self.appDelegate.loggedInStudent?.firstName = studentData["firstName"] as? String
                         self.appDelegate.loggedInStudent?.lastName = studentData["lastName"] as? String
                    }
               } else {
                    self.displayError(errorString)
               }
          }
     }
     
     // ************************************************
     // * Login Successful, Move to Tab Bar Controller *
     // ************************************************
     func completeLogin() {
          dispatch_async(dispatch_get_main_queue(), {
               self.passwordTextField.text = "" // remove password 
               self.debugTextLabel.text = "Login Success!"
               let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
               self.activityIndicator.stopAnimating()
               self.presentViewController(controller, animated: true, completion: nil)
          })
     }
     
     // ***********************************
     // * Update Error Label with Message *
     // ***********************************
     func displayError(errorString: String?) {
          dispatch_async(dispatch_get_main_queue(), {
               if let errorString = errorString {
                    self.debugTextLabel.text = errorString
               }
          })
     }
     
     // *****************************
     // * Open Udacity Sign Up Page *
     // *****************************
     @IBAction func signUpButton(sender: AnyObject) {
          if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
               UIApplication.sharedApplication().openURL(url)
          }
     }
     
     // *************************************
     // * Shake the screen if login failure *
     // *************************************
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
     
     // ***********************************
     // * Blur Activity View During Login *
     // ***********************************
     func blurActivityView() {
          let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
          blurEffectView = UIVisualEffectView(effect: blurEffect)
          blurEffectView.frame = view.bounds
          blurEffectView.alpha = 0.5
          view.addSubview(blurEffectView)
     }
     
     func removeBlur() {
          dispatch_async(dispatch_get_main_queue(), {
               if self.blurEffectView != nil {
                    self.blurEffectView.removeFromSuperview()
               }
          })
     }
}