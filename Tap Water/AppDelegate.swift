//
//  AppDelegate.swift
//  Tap Water
//
//  Created by Stephen Kyles on 12/11/15.
//  Copyright © 2015 Blue Owl Labs. All rights reserved.
//

import UIKit
import CoreData

let action = UIMutableUserNotificationAction()
let category = UIMutableUserNotificationCategory()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        action.identifier = "addglass"
        action.title = "Add A Glass"
        action.activationMode = .background
        action.isDestructive = false
        
        category.identifier = "addglasscat"
        category.setActions([action], for: .default)
        
        let settings = UIApplication.shared.currentUserNotificationSettings
        
        if (settings!.types.intersection(UIUserNotificationType.alert) != [] && GetSettingsAttribute(Notification, key: NotificationKey)) {
            ScheduleNotifications(true)
        } else {
            ScheduleNotifications(false)
            UpdateSettingsAttribute(Notification, key: NotificationKey, value: false)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        UpdateAppBadge(application)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        ScheduleNotifications(true)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        let day = GetCurrentDay()
        day.totalGlassesDrank = day.totalGlassesDrank + 1
        UpdateCurrentDay(day)
        UpdateAppBadge(application)
        
        completionHandler()
    }
    
    /*func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?,
    reply: (([NSObject : AnyObject]!) -> Void)!) {
    var day = GetCurrentDay()
    
    if let s = userInfo?["totalGlassesDrank"] as? Int {
    day.totalGlassesDrank = day.totalGlassesDrank + s
    UpdateCurrentDay(day)
    
    reply(["totalGlassesDrank": day.totalGlassesDrank, "totalGlassesGoal" : day.totalGlassesGoal])
    UpdateAppBadge(application)
    }
    else if let s = userInfo?["getDaily"] as? Int {
    reply(["totalGlassesDrank": day.totalGlassesDrank, "totalGlassesGoal" : day.totalGlassesGoal])
    }
    }*/
    
    func UpdateAppBadge(_ application: UIApplication) {
        let day = GetCurrentDay()
        let glassesLeft = day.totalGlassesGoal - day.totalGlassesDrank
        let settings = UIApplication.shared.currentUserNotificationSettings
        
        if (settings!.types.intersection(UIUserNotificationType.badge) != []) {
            if glassesLeft > 0 {
                application.applicationIconBadgeNumber = glassesLeft
            } else {
                application.applicationIconBadgeNumber = 0
            }
        } else {
            application.applicationIconBadgeNumber = 0
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "BOL.Hydrate" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Tap_Water", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Tap_Water.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
}

