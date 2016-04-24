//
//  CoreDataHelper.swift
//  Swift Controls
//
//  Created by Stephen Kyles on 9/13/14.
//  Copyright (c) 2014 Blue Owl Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Entity)
class Entity: NSManagedObject {
    @NSManaged var name: String
}

func ManagedContext() -> NSManagedObjectContext {
    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context = appDelegate.managedObjectContext
    
    return context!
}

// Onboarding

func hasSeenOnBoarding() -> Bool {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:"OnBoard")
    let fetchedResults = try? managedContext!.executeFetchRequest(fetchRequest)
    
    var seen = false
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            let current = results[0] as! NSManagedObject
            
            seen = current.valueForKey("hasSeen") as! Bool
        }
    } else {
        setOnBoarding(seen)
    }
    
    return seen
}

func setOnBoarding(hasSeen: Bool) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:"OnBoard")
    let fetchedResults = try? managedContext!.executeFetchRequest(fetchRequest)
    
    if fetchedResults?.count > 0 {
        if let dayResults = fetchedResults {
            let current = dayResults[0] as! NSManagedObject
            
            current.setValue(hasSeen, forKey: "hasSeen")
            
            do {
                try managedContext!.save()
            } catch let error1 as NSError {
                print("Could not save \(error1), \(error1.userInfo)")
            }
        }
    } else {
        let entity =  NSEntityDescription.entityForName("OnBoard", inManagedObjectContext: managedContext!)
        let seenObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        seenObject.setValue(hasSeen, forKey: "hasSeen")
        
        do {
            try managedContext!.save()
        } catch let error1 as NSError {
            print("Could not save \(error1), \(error1.userInfo)")
        }
    }
}

// Days

func savePastDay(day: Day) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let entity =  NSEntityDescription.entityForName("PastDays", inManagedObjectContext: managedContext!)
    let waterObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
    
    waterObject.setValue(day.todaysDate, forKey: "todaysDate")
    waterObject.setValue(day.totalGlassesDrank, forKey: "totalGlassesDrank")
    waterObject.setValue(day.totalGlassesGoal, forKey: "totalGlassesGoal")
    waterObject.setValue(day.ouncesPerGlass, forKey: "ouncesPerGlass")
    
    do {
        try managedContext!.save()
    } catch let error1 as NSError {
        print("Could not save \(error1), \(error1.userInfo)")
    }
}

func getPastSevenDays(date: NSDate) -> NSArray {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let dayFetchRequest = NSFetchRequest(entityName:"PastDays")

    dayFetchRequest.sortDescriptors = [NSSortDescriptor(key: "todaysDate", ascending: false)]
    dayFetchRequest.fetchLimit = 6
    
    let dayFetchedResults = try? managedContext!.executeFetchRequest(dayFetchRequest)
    
    let days: NSMutableArray = [0,0,0,0,0,0,0]
    
    if dayFetchedResults?.count > 0 {
        if let dayResults = dayFetchedResults {
            if dayResults.count == 6 {
                let reversedResults = dayResults.reverse() as Array
                
                for index in 0..<reversedResults.count {
                    days.replaceObjectAtIndex(index, withObject: reversedResults[index].valueForKey("totalGlassesDrank") as! Int)
                }
            } else {
                for index in 0..<dayResults.count {
                    days.replaceObjectAtIndex((days.count - 2) - index, withObject: dayResults[index].valueForKey("totalGlassesDrank") as! Int)
                    
                    print(dayResults[index].valueForKey("todaysDate") as! NSDate)
                }
            }
        }
    }
    
    return days
}

func SaveCurrentDay(day: Day) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let entity =  NSEntityDescription.entityForName("Day", inManagedObjectContext: managedContext!)
    let todaysWaterObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
    
    todaysWaterObject.setValue(day.todaysDate, forKey: "todaysDate")
    todaysWaterObject.setValue(day.totalGlassesDrank, forKey: "totalGlassesDrank")
    todaysWaterObject.setValue(day.totalGlassesGoal, forKey: "totalGlassesGoal")
    todaysWaterObject.setValue(day.ouncesPerGlass, forKey: "ouncesPerGlass")
    
    do {
        try managedContext!.save()
    } catch let error1 as NSError {
        print("Could not save \(error1), \(error1.userInfo)")
    }
}

func GetCurrentDay() -> Day {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let dayFetchRequest = NSFetchRequest(entityName:"Day")
    let dayFetchedResults = try? managedContext!.executeFetchRequest(dayFetchRequest)
    
    let day = Day(date: NSDate(), drank: 0, goal: 8, ounces: 8)
    
    if dayFetchedResults?.count > 0 {
        if let dayResults = dayFetchedResults {
            let currentDay = dayResults[0] as! NSManagedObject
            
            day.todaysDate = currentDay.valueForKey("todaysDate") as! NSDate
            day.totalGlassesDrank = currentDay.valueForKey("totalGlassesDrank") as! Int
            day.totalGlassesGoal = currentDay.valueForKey("totalGlassesGoal") as! Int
            day.ouncesPerGlass = currentDay.valueForKey("ouncesPerGlass") as! Int
        }
        
        if (!AreDatesSameDay(day.todaysDate, dateTwo: NSDate())) {
            let daysDifference = calculateNumberOfDaysDifference(day.todaysDate, dateTwo: NSDate())
            
            if daysDifference > 1 {
                for index in 1...daysDifference-1 {
                    calculateAverage(0)
                    savePastDay(Day(date: calculateNextDate(day.todaysDate, index: index), drank: 0, goal: day.totalGlassesGoal, ounces: day.ouncesPerGlass))
                }
            }

            calculateAverage(CGFloat(day.totalGlassesDrank))
            savePastDay(day)
            day.totalGlassesDrank = 0
            day.todaysDate = NSDate()
            UpdateCurrentDay(day)
        }
    } else {
        SaveCurrentDay(day)
    }
    
    return day
}

func UpdateCurrentDay(day: Day) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let dayFetchRequest = NSFetchRequest(entityName:"Day")
    let dayFetchedResults = try? managedContext!.executeFetchRequest(dayFetchRequest)

    if dayFetchedResults?.count > 0 {
        if let dayResults = dayFetchedResults {
            let currentDay = dayResults[0] as! NSManagedObject
            
            currentDay.setValue(day.todaysDate, forKey: "todaysDate")
            currentDay.setValue(day.totalGlassesDrank, forKey: "totalGlassesDrank")
            currentDay.setValue(day.totalGlassesGoal, forKey: "totalGlassesGoal")
            currentDay.setValue(day.ouncesPerGlass, forKey: "ouncesPerGlass")
            
            do {
                try managedContext!
                    .save()
            } catch let error1 as NSError {
                print("Could not save \(error1), \(error1.userInfo)")
            }
        }
    } else {
        SaveCurrentDay(day)
    }
}

func AreDatesSameDay(dateOne: NSDate, dateTwo: NSDate) -> Bool {
    let flags: NSCalendarUnit = [.Day, .Month, .Year]
    let calender = NSCalendar.currentCalendar()
    let compOne: NSDateComponents = calender.components(flags, fromDate: dateOne)
    let compTwo: NSDateComponents = calender.components(flags, fromDate: dateTwo)
    
    return (compOne.day == compTwo.day && compOne.month == compTwo.month && compOne.year == compTwo.year)
}

func calculateNumberOfDaysDifference(dateOne: NSDate, dateTwo: NSDate) -> Int {
    let calendar: NSCalendar = NSCalendar.currentCalendar()
    let flags: NSCalendarUnit = .Day
    let components = calendar.components(flags, fromDate: dateOne, toDate: dateTwo, options: [])
    
    return components.day
}

func calculateNextDate(date: NSDate, index: Int) -> NSDate {
    let dayComponent: NSDateComponents = NSDateComponents()
    dayComponent.day = index;
    
    let calendar: NSCalendar = NSCalendar.currentCalendar()
    return calendar.dateByAddingComponents(dayComponent, toDate: date, options: [])!
}

// Settings

func SetSettingsAttribute(entityName: NSString, key: NSString, value: Bool) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let entity =  NSEntityDescription.entityForName(entityName as String, inManagedObjectContext: managedContext!)
    let object = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    
    object.setValue(value, forKey: key as String)
    
    do {
        try managedContext!.save()
    } catch let error1 as NSError {
        print("Could not save \(error1), \(error1.userInfo)")
    }
}

func UpdateSettingsAttribute(entityName: NSString, key: NSString, value: Bool) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: entityName as String)
    let fetchedResults = try? managedContext!.executeFetchRequest(fetchRequest)
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            let current = results[0] as! NSManagedObject
            
            current.setValue(value, forKey: key as String)
            
            do {
                try managedContext!.save()
            } catch let error1 as NSError {
                print("Could not save \(error1), \(error1.userInfo)")
            }
        }
    } else {
        SetSettingsAttribute(entityName, key: key, value: value)
    }
}

func GetSettingsAttribute(entityName: NSString, key: NSString) -> Bool {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: entityName as String)
    let fetchedResults = try? managedContext!.executeFetchRequest(fetchRequest)
    
    var value = true
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            let current = results[0] as! NSManagedObject
            
            value = current.valueForKey(key as String) as! Bool
        }
    } else {
        SetSettingsAttribute(entityName, key: key, value: value)
    }
    
    return value
}

// Notifications

func SaveNotifications(notifications: NSArray) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:"Notifications")
    let fetchedResults = try? managedContext!.executeFetchRequest(fetchRequest)
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            for current in 0..<results.count {
                managedContext!.deleteObject(results[current] as! NSManagedObject)
                
                do {
                    try managedContext!.save()
                } catch let error1 as NSError {
                    print("Could not save \(error1), \(error1.userInfo)")
                }
            }
            
            let entity =  NSEntityDescription.entityForName("Notifications", inManagedObjectContext: managedContext!)
            
            for note in 0..<notifications.count {
                let notificationObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                notificationObject.setValue(notifications[note], forKey: "hour")
                
                do {
                    try managedContext!.save()
                } catch let error1 as NSError {
                    print("Could not save \(error1), \(error1.userInfo)")
                }
            }  
        }
    } else {
        let entity =  NSEntityDescription.entityForName("Notifications", inManagedObjectContext: managedContext!)
        
        for note in 0..<notifications.count {
            let notificationObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            notificationObject.setValue(notifications[note], forKey: "hour")
            
            do {
                try managedContext!.save()
            } catch let error1 as NSError {
                print("Could not save \(error1), \(error1.userInfo)")
            }
        }
    }
}

func GetNotifications(hours: NSMutableArray) -> NSMutableArray {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:"Notifications")
    let fetchedResults = try? managedContext!.executeFetchRequest(fetchRequest)
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            hours.removeAllObjects()
            
            for current in 0..<results.count {
                hours.addObject(results[current].valueForKey("hour") as! Int)
            }
        }
    } else {
        SaveNotifications(hours)
    }

    return hours
}

func ScheduleNotifications(value: Bool) {
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    
    if value {
        let hours = GetNotifications([])
        
        for (var i=0; i<hours.count; i++) {
            let date = NSCalendar.currentCalendar().dateBySettingHour(hours[i] as! Int, minute: 0, second: 0, ofDate: NSDate(), options: [])
            let localNotification = UILocalNotification()
            
            localNotification.fireDate = date
            localNotification.alertBody = "Time to drink some water!"
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.repeatInterval = NSCalendarUnit.Day
            localNotification.category = "addglasscat"
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
}

// Average

func calculateAverage(newAmount: CGFloat) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName:"CurrentAverage")
    let fetchedResults = try? managedContext!.executeFetchRequest(fetchRequest)
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            let current = results[0] as! NSManagedObject
            
            var value = current.valueForKey("average") as! CGFloat
            
            value = (value + newAmount) / 2
            current.setValue(value, forKey: "average")
            
            do {
                try managedContext!.save()
            } catch let error1 as NSError {
                print("Could not save \(error1), \(error1.userInfo)")
            }
        }
    } else {
        let entity =  NSEntityDescription.entityForName("CurrentAverage", inManagedObjectContext: managedContext!)
        let averageObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        averageObject.setValue(newAmount, forKey: "average")
        
        do {
            try managedContext!.save()
        } catch let error1 as NSError {
            print("Could not save \(error1), \(error1.userInfo)")
        }
    }
}

func getAverage() -> CGFloat {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:"CurrentAverage")
    let fetchedResults = try? managedContext!.executeFetchRequest(fetchRequest)
    
    var value: CGFloat = 0.0
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            let current = results[0] as! NSManagedObject
            
            value = current.valueForKey("average") as! CGFloat
        }
    }
    
    return value
}