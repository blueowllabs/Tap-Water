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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc(Entity)
class Entity: NSManagedObject {
    @NSManaged var name: String
}

func ManagedContext() -> NSManagedObjectContext {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = appDelegate.managedObjectContext
    
    return context!
}

// Onboarding

func hasSeenOnBoarding() -> Bool {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"OnBoard")
    let fetchedResults = try? managedContext!.fetch(fetchRequest)
    
    var seen = false
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            let current = results[0] as! NSManagedObject
            
            seen = current.value(forKey: "hasSeen") as! Bool
        }
    } else {
        setOnBoarding(seen)
    }
    
    return seen
}

func setOnBoarding(_ hasSeen: Bool) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"OnBoard")
    let fetchedResults = try? managedContext!.fetch(fetchRequest)
    
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
        let entity =  NSEntityDescription.entity(forEntityName: "OnBoard", in: managedContext!)
        let seenObject = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        seenObject.setValue(hasSeen, forKey: "hasSeen")
        
        do {
            try managedContext!.save()
        } catch let error1 as NSError {
            print("Could not save \(error1), \(error1.userInfo)")
        }
    }
}

// Days

func savePastDay(_ day: Day) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let entity =  NSEntityDescription.entity(forEntityName: "PastDays", in: managedContext!)
    let waterObject = NSManagedObject(entity: entity!, insertInto:managedContext)
    
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

func getPastSevenDays(_ date: Date) -> NSArray {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let dayFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"PastDays")

    dayFetchRequest.sortDescriptors = [NSSortDescriptor(key: "todaysDate", ascending: false)]
    dayFetchRequest.fetchLimit = 6
    
    let dayFetchedResults = try? managedContext!.fetch(dayFetchRequest)
    
    let days: NSMutableArray = [0,0,0,0,0,0,0]
    
    if dayFetchedResults?.count > 0 {
        if let dayResults = dayFetchedResults {
            if dayResults.count == 6 {
                let reversedResults = dayResults.reversed() as Array
                
                for index in 0..<reversedResults.count {
                    days.replaceObject(at: index, with: (reversedResults[index] as AnyObject).value(forKey: "totalGlassesDrank") as! Int)
                }
            } else {
                for index in 0..<dayResults.count {
                    days.replaceObject(at: (days.count - 2) - index, with: (dayResults[index] as AnyObject).value(forKey: "totalGlassesDrank") as! Int)
                    
                    print((dayResults[index] as AnyObject).value(forKey: "todaysDate") as! Date)
                }
            }
        }
    }
    
    return days
}

func SaveCurrentDay(_ day: Day) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let entity =  NSEntityDescription.entity(forEntityName: "Day", in: managedContext!)
    let todaysWaterObject = NSManagedObject(entity: entity!, insertInto:managedContext)
    
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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let dayFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Day")
    let dayFetchedResults = try? managedContext!.fetch(dayFetchRequest)
    
    let day = Day(date: Date(), drank: 0, goal: 8, ounces: 8)
    
    if dayFetchedResults?.count > 0 {
        if let dayResults = dayFetchedResults {
            let currentDay = dayResults[0] as! NSManagedObject
            
            day.todaysDate = currentDay.value(forKey: "todaysDate") as! Date
            day.totalGlassesDrank = currentDay.value(forKey: "totalGlassesDrank") as! Int
            day.totalGlassesGoal = currentDay.value(forKey: "totalGlassesGoal") as! Int
            day.ouncesPerGlass = currentDay.value(forKey: "ouncesPerGlass") as! Int
        }
        
        if (!AreDatesSameDay(day.todaysDate, dateTwo: Date())) {
            let daysDifference = calculateNumberOfDaysDifference(day.todaysDate, dateTwo: Date())
            
            if daysDifference > 1 {
                for index in 1...daysDifference-1 {
                    calculateAverage(0)
                    savePastDay(Day(date: calculateNextDate(day.todaysDate, index: index), drank: 0, goal: day.totalGlassesGoal, ounces: day.ouncesPerGlass))
                }
            }

            calculateAverage(CGFloat(day.totalGlassesDrank))
            savePastDay(day)
            day.totalGlassesDrank = 0
            day.todaysDate = Date()
            UpdateCurrentDay(day)
        }
    } else {
        SaveCurrentDay(day)
    }
    
    return day
}

func UpdateCurrentDay(_ day: Day) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let dayFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Day")
    let dayFetchedResults = try? managedContext!.fetch(dayFetchRequest)

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

func AreDatesSameDay(_ dateOne: Date, dateTwo: Date) -> Bool {
    let flags: NSCalendar.Unit = [.day, .month, .year]
    let calender = Calendar.current
    let compOne: DateComponents = (calender as NSCalendar).components(flags, from: dateOne)
    let compTwo: DateComponents = (calender as NSCalendar).components(flags, from: dateTwo)
    
    return (compOne.day == compTwo.day && compOne.month == compTwo.month && compOne.year == compTwo.year)
}

func calculateNumberOfDaysDifference(_ dateOne: Date, dateTwo: Date) -> Int {
    let calendar: Calendar = Calendar.current
    let flags: NSCalendar.Unit = .day
    let components = (calendar as NSCalendar).components(flags, from: dateOne, to: dateTwo, options: [])
    
    return components.day!
}

func calculateNextDate(_ date: Date, index: Int) -> Date {
    var dayComponent: DateComponents = DateComponents()
    dayComponent.day = index;
    
    let calendar: Calendar = Calendar.current
    return (calendar as NSCalendar).date(byAdding: dayComponent, to: date, options: [])!
}

// Settings

func SetSettingsAttribute(_ entityName: NSString, key: NSString, value: Bool) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let entity =  NSEntityDescription.entity(forEntityName: entityName as String, in: managedContext!)
    let object = NSManagedObject(entity: entity!, insertInto: managedContext)
    
    object.setValue(value, forKey: key as String)
    
    do {
        try managedContext!.save()
    } catch let error1 as NSError {
        print("Could not save \(error1), \(error1.userInfo)")
    }
}

func UpdateSettingsAttribute(_ entityName: NSString, key: NSString, value: Bool) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName as String)
    let fetchedResults = try? managedContext!.fetch(fetchRequest)
    
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

func GetSettingsAttribute(_ entityName: NSString, key: NSString) -> Bool {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName as String)
    let fetchedResults = try? managedContext!.fetch(fetchRequest)
    
    var value = true
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            let current = results[0] as! NSManagedObject
            
            value = current.value(forKey: key as String) as! Bool
        }
    } else {
        SetSettingsAttribute(entityName, key: key, value: value)
    }
    
    return value
}

// Notifications

func SaveNotifications(_ notifications: NSArray) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Notifications")
    let fetchedResults = try? managedContext!.fetch(fetchRequest)
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            for current in 0..<results.count {
                managedContext!.delete(results[current] as! NSManagedObject)
                
                do {
                    try managedContext!.save()
                } catch let error1 as NSError {
                    print("Could not save \(error1), \(error1.userInfo)")
                }
            }
            
            let entity =  NSEntityDescription.entity(forEntityName: "Notifications", in: managedContext!)
            
            for note in 0..<notifications.count {
                let notificationObject = NSManagedObject(entity: entity!, insertInto:managedContext)
                notificationObject.setValue(notifications[note], forKey: "date")
                
                do {
                    try managedContext!.save()
                } catch let error1 as NSError {
                    print("Could not save \(error1), \(error1.userInfo)")
                }
            }  
        }
    } else {
        let entity =  NSEntityDescription.entity(forEntityName: "Notifications", in: managedContext!)
        
        for note in 0..<notifications.count {
            let notificationObject = NSManagedObject(entity: entity!, insertInto:managedContext)
            notificationObject.setValue(notifications[note], forKey: "date")
            
            do {
                try managedContext!.save()
            } catch let error1 as NSError {
                print("Could not save \(error1), \(error1.userInfo)")
            }
        }
    }    
}

func GetNotifications(_ hours: NSMutableArray) -> NSMutableArray {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Notifications")
    let fetchedResults = try? managedContext!.fetch(fetchRequest)
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            hours.removeAllObjects()
            
            for current in 0..<results.count {
                hours.add((results[current] as AnyObject).value(forKey: "date") as! Date)
            }
        }
    } else {
        SaveNotifications(hours)
    }

    return hours
}

func ScheduleNotifications(_ value: Bool) {
    UIApplication.shared.cancelAllLocalNotifications()
    
    if value {
        let dates = GetNotifications([])
        
        for i in 0 ..< dates.count {
            let currentDate = Date()
            let date = dates[i]
            let comp = (Calendar.current as NSCalendar).components([.hour, .minute, .second], from: date as! Date)
            let fireDate = (Calendar.current as NSCalendar)
                .date(bySettingHour: comp.hour!, minute: comp.minute!, second: comp.second!, of: currentDate, options: [])
            let localNotification = UILocalNotification()
            
            localNotification.fireDate = fireDate
            localNotification.alertBody = "Time to drink some water!"
            localNotification.timeZone = TimeZone.current
            localNotification.repeatInterval = NSCalendar.Unit.day
            localNotification.category = "addglasscat"
            
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
}

// Average

func calculateAverage(_ newAmount: CGFloat) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CurrentAverage")
    let fetchedResults = try? managedContext!.fetch(fetchRequest)
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            let current = results[0] as! NSManagedObject
            
            var value = current.value(forKey: "average") as! CGFloat
            
            value = (value + newAmount) / 2
            current.setValue(value, forKey: "average")
            
            do {
                try managedContext!.save()
            } catch let error1 as NSError {
                print("Could not save \(error1), \(error1.userInfo)")
            }
        }
    } else {
        let entity =  NSEntityDescription.entity(forEntityName: "CurrentAverage", in: managedContext!)
        let averageObject = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        averageObject.setValue(newAmount, forKey: "average")
        
        do {
            try managedContext!.save()
        } catch let error1 as NSError {
            print("Could not save \(error1), \(error1.userInfo)")
        }
    }
}

func getAverage() -> CGFloat {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CurrentAverage")
    let fetchedResults = try? managedContext!.fetch(fetchRequest)
    
    var value: CGFloat = 0.0
    
    if fetchedResults?.count > 0 {
        if let results = fetchedResults {
            let current = results[0] as! NSManagedObject
            
            value = current.value(forKey: "average") as! CGFloat
        }
    }
    
    return value
}
