//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Christopher Burgess on 6/6/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

     var window: UIWindow?

     // currently logged in student (user)
     var loggedInStudent : Student?
     // array of student data from Parse API
     //var allStudents : [Student]?
     var allStudents : [Student] = [Student]()
     
     //var studentDataArr: [Student] = [Student]()
     
     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
          return true
     }
}

