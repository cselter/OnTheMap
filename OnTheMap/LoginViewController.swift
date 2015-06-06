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
                    // transition to tab controller
                    // self.completeLogin()
               }
               else {
                    println(error)
                    self.displayError(error)
               }

               
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

}

