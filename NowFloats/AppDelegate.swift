//
//  AppDelegate.swift
//  NowFloats
//
//  Created by Mahesh Y on 8/17/16.
//  Copyright © 2016 CX. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices
import MagicalRecord



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        UITabBar.appearance().tintColor = CXAppConfig.sharedInstance.getAppTheamColor()
        UITabBar.appearance().backgroundColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.setUpMagicalDB()
        self.configure()
      //  blockOperationsTest1()
       // self.setUpSidePanelview()
        return true
    }
    
    func blockOperationsTest1(){
        
        var operationQueue = NSOperationQueue()
        
        let operation1 : NSBlockOperation = NSBlockOperation (block: {
            self.doCalculations()
            
            let operation2 : NSBlockOperation = NSBlockOperation (block: {
                
                self.doSomeMoreCalculations()
                
            })
            operationQueue.addOperation(operation2)
        })
        operationQueue.addOperation(operation1)
    }
    
    func doCalculations(){
        NSLog("do Calculations")
        for i in 100...105{
            print("i in do calculations is \(i)")
            sleep(1)
        }
    }
    
    func doSomeMoreCalculations(){
        NSLog("do Some More Calculations")
        for j in 1...5{
            print("j in do some more calculations is \(j)")
            sleep(1)
        }
        
    }
    
    //MARK: Sidepanel setup
    func setUpSidePanelview(){
    
           /* let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        
        
        let homeView = storyBoard.instantiateViewControllerWithIdentifier("LeftViewController") as! LeftViewController
        
        let menuVC = storyBoard.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        //        let menuVC = storyBoard.instantiateViewControllerWithIdentifier("TabBar") as! UITabBarController

        
    let navHome = UINavigationController(rootViewController: menuVC)
        let revealVC = SWRevealViewController(rearViewController: homeView, frontViewController: navHome)
        revealVC.delegate = self
        revealVC.rearViewRevealWidth = CXAppConfig.sharedInstance.mainScreenSize().width-50
        self.window?.rootViewController = revealVC
        self.window?.makeKeyAndVisible()*/
    
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        /*   let products:CX_Products = (self.products[indexPath.item] as? CX_Products)!
         
         let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
         let productDetails = storyBoard.instantiateViewControllerWithIdentifier("PRODUCT_DETAILS") as! ProductDetailsViewController
         productDetails.productString = products.json
         self.navigationController?.pushViewController(productDetails, animated: true)*/
        
//        let viewController = window?.rootViewController as! CXNavDrawer
//        viewController.restoreUserActivityState(userActivity)
//        
//        return true

        if userActivity.activityType == CSSearchableItemActionType{
            let identifier = userActivity.userInfo![CSSearchableItemActivityIdentifier]
            NSNotificationCenter.defaultCenter().postNotificationName("DisplaySearchResult", object: identifier)
        
        }
        return true
    }

    // MARK: - Core Data stack

    func setUpMagicalDB() {
        //MagicalRecord.setupCoreDataStackWithStoreNamed("Silly_Monks")
        NSPersistentStoreCoordinator.MR_setDefaultStoreCoordinator(persistentStoreCoordinator)
        NSManagedObjectContext.MR_initializeDefaultContextWithCoordinator(persistentStoreCoordinator)
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.CX.NowFloats" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("NowFloats", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        print(url)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        print(managedObjectContext.hasChanges)
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: Loader configuration
    
    func configure (){
        var config : LoadingView.Config = LoadingView.Config()
        config.size = 100
        config.backgroundColor = UIColor.blackColor() //UIColor(red:0.03, green:0.82, blue:0.7, alpha:1)
        config.spinnerColor = UIColor.whiteColor()//UIColor(red:0.88, green:0.26, blue:0.18, alpha:1)
        config.titleTextColor = UIColor.whiteColor()//UIColor(red:0.88, green:0.26, blue:0.18, alpha:1)
        config.spinnerLineWidth = 2.0
        config.foregroundColor = UIColor.blackColor()
        config.foregroundAlpha = 0.5
        LoadingView.setConfig(config)
    }


}

