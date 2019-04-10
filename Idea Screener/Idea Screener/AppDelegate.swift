//
//  AppDelegate.swift
//  Idea Screener
//
//  Created by Silver on 02.04.2018.
//  Copyright © 2018 Silver Star. All rights reserved.
//

import UIKit
import UserNotifications
import AVKit
import AVFoundation
import GoogleSignIn
import FBSDKCoreKit
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Stripe Configuration
        Stripe.setDefaultPublishableKey(STRIPE_PUBLIC_KEY)
        
//        // Initialize GOOGLE sign-in
        GIDSignIn.sharedInstance().clientID = GOOGLE_CLIENT_ID
//        GIDSignIn.sharedInstance().delegate = self
        
        // Sets navigationBar's background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().backgroundColor = .clear
        
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        
        registerForPushNotifications()
        
        isNotificationLaunch(launchOptions: launchOptions, userInfo: nil)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            let googleDidHandle = GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
            
            let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)
            
            return googleDidHandle || facebookDidHandle
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.instance.saveContext()
    }

    

}


// Extension for UNUserNotificationCenterDelegate and custom functions

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    // ---------------NOTIFICATION DELEGATES---------------
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
        DEVICE_TOKEN = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo as? [String: Any]
        print("did receive")
        
        isNotificationLaunch(launchOptions: nil, userInfo: userInfo)
        
        completionHandler()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent")
        completionHandler([.badge, .alert, .sound])
    }
    
    // -----------------------------------------
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            // 1. Check if permission granted
            guard granted else { return }
            self.getNotificationSettings()
        }
        
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
        
    }
    
    func isNotificationLaunch(launchOptions: [UIApplicationLaunchOptionsKey: Any]?, userInfo: [String: Any]?) {
        
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            
            notificationStart = true
            
            if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
                
                if let survey: Dictionary<String,Any> = notification["survey"] as? Dictionary {
                    
                    if let surveyType = survey["survey_type"] as? String {
                        respondSurvey.type = surveyType
                    }
                    
                    if let id = survey["id"] as? Int {
                        respondSurvey.id = id
                    }
                    
                    if let title = survey["title"] as? String {
                        respondSurvey.problem = title
                    }
                    
                    if let userId = survey["user_id"] as? Int {
                        respondSurvey.userId = userId
                    }
                    
                }
                
                if let questions: Array<Dictionary<String,Any>> = notification["questions"] as? Array {
                    
                    if questions.count > 0 {
                        
                        for question in questions {
                            
                            if let id = question["id"] as? Int {
                                respondSurvey.questionId = id
                            }
                            
                        }
                        
                    }
                    
                }
                
                if let solutions: Array<Dictionary<String,Any>> = notification["solutions"] as? Array {
                    
                    if solutions.count > 0 {
                        
                        var solutionsArr = [RespondSolution]()
                        
                        for solution in solutions {
                            
                            let mySolution = RespondSolution()
                            
                            mySolution.userId = respondSurvey.userId
                            mySolution.surveyId = respondSurvey.id
                            
                            if let id = solution["id"] as? Int {
                                mySolution.id = id
                            }
                            
                            if let content = solution["content"] as? String {
                                mySolution.content = content
                            }
                            
                            if let video: Dictionary<String,Any> = solution["video"] as? Dictionary {
                                if let stringUrl = video["url"] as? String {
                                    if let url = URL(string: SERVER_URL + stringUrl) {
                                        mySolution.video = AVPlayer(url: url as URL)
                                    }
                                }
                            }
                            
                            if let image: Dictionary<String,Any> = solution["image"] as? Dictionary {
                                if let stringUrl = image["url"] as? String {
                                    mySolution.imageStringUrl = SERVER_URL + stringUrl
                                }
                            }
                            
                            solutionsArr.append(mySolution)
                            
                        }
                        
                        respondSurvey.solutions = solutionsArr
                        
                    }
                    
                }
                
            }
            
        }
        
        if userInfo != nil {
            
            notificationStart = true
            
            let vc = window?.visibleViewController

            vc?.navigationController?.popToRootViewController(animated: true)
            
            if let survey: Dictionary<String,Any> = userInfo!["survey"] as? Dictionary {
                
                if let surveyType = survey["survey_type"] as? String {
                    respondSurvey.type = surveyType
                }
                
                if let title = survey["title"] as? String {
                    respondSurvey.problem = title
                }
                
                if let userId = survey["user_id"] as? Int {
                    respondSurvey.userId = userId
                }
                
                if let id = survey["id"] as? Int {
                    respondSurvey.id = id
                }
                
            }
            
            if let questions: Array<Dictionary<String,Any>> = userInfo!["questions"] as? Array {
                
                if questions.count > 0 {
                    
                    for question in questions {
                        
                        if let id = question["id"] as? Int {
                            respondSurvey.questionId = id
                        }
                        
                    }
                    
                }
                
            }
            
            if let solutions: Array<Dictionary<String,Any>> = userInfo!["solutions"] as? Array {
                
                if solutions.count > 0 {
                    
                    var solutionsArr = [RespondSolution]()
                    
                    for solution in solutions {
                        
                        let mySolution = RespondSolution()
                        
                        mySolution.userId = respondSurvey.userId
                        mySolution.surveyId = respondSurvey.id
                        
                        if let id = solution["id"] as? Int {
                            mySolution.id = id
                        }
                        
                        if let content = solution["content"] as? String {
                            mySolution.content = content
                        }
                        
                        if let video: Dictionary<String,Any> = solution["video"] as? Dictionary {
                            if let stringUrl = video["url"] as? String {
                                if let url = URL(string: SERVER_URL + stringUrl) {
                                    mySolution.video = AVPlayer(url: url as URL)
                                }
                            }
                        }
                        
                        if let image: Dictionary<String,Any> = solution["image"] as? Dictionary {
                            if let stringUrl = image["url"] as? String {
                                mySolution.imageStringUrl = SERVER_URL + stringUrl
                            }
                        }
                        
                        solutionsArr.append(mySolution)
                        
                    }
                    
                    respondSurvey.solutions = solutionsArr
                    
                }
                
            }
            
            if let mainVC = vc as? MainViewController {
                
                switch respondSurvey.type {
                case "single_question":
                    mainVC.performSegue(withIdentifier: "GotoSingleOptionResponse", sender: nil)
                case "multiple_question":
                    mainVC.performSegue(withIdentifier: "GotoMultipleOptionResponse", sender: nil)
                case "test_multiple_question":
                    mainVC.performSegue(withIdentifier: "GotoTestMultipleOptionResponse", sender: nil)
                default:
                    print("hz")
                    
                }
                
            }
            
        }
        
    }
    
    
}

