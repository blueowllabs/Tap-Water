//
//  NotificationsViewController.swift
//  WaterUp
//
//  Created by Stephen Kyles on 8/15/15.
//  Copyright (c) 2015 Blue Owl Labs. All rights reserved.
//

import UIKit

let NotiticationCellId = "notificationCell"

func calculateNotificationTimes(dailyGlassGoal: Int) -> NSMutableArray {
    let numberToSchedule = dailyGlassGoal
    let notificationTimes: NSMutableArray = []
    let offset = numberToSchedule > 7 ? 1 : 2
    
    var fireDate = NSCalendar.currentCalendar()
        .dateBySettingHour(8, minute: 0, second: 0, ofDate: NSDate(), options: [])
    
    for _ in 0..<numberToSchedule {
        notificationTimes.addObject(fireDate!)
        fireDate = NSCalendar.currentCalendar()
            .dateByAddingUnit(.Hour, value: offset, toDate: fireDate!, options: [])
    }
    
    return notificationTimes
}

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var day: Day!
    var times: NSMutableArray = []
    var timeStrings: NSMutableArray = []
    var shadowView: UIView!
    var infoView: UIView!
    var pickerHours: NSMutableArray = []
    var pickerMinutes: NSMutableArray = []
    var pickerTime: NSMutableArray = []
    var tempHour: Int = 1
    var tempMinute: Int = 00
    var tempTime: String = "AM"
    
    // test
    var datePicker: UIDatePicker!

    @IBOutlet weak var enableSwitch: UISwitch!
    @IBOutlet weak var notificationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backbutton = UIBarButtonItem(
            image: UIImage(named: "back"),
            style: .Plain,
            target: self,
            action: #selector(NotificationsViewController.goBack))
        
        navigationItem.leftBarButtonItem = backbutton
        
        title = "Daily Notifications"
        
        configureNotifications()
        
        if GetSettingsAttribute(Notification, key: NotificationKey) {
            enableSwitch.setOn(true, animated: true)
            notificationTableView.hidden = false
            displayAddButton()
        } else {
            enableSwitch.setOn(false, animated: true)
            notificationTableView.hidden = true
            navigationItem.rightBarButtonItem = nil
        }

        enableSwitch.addTarget(self, action: #selector(NotificationsViewController.stateChanged(_:)),
                               forControlEvents: UIControlEvents.ValueChanged)
        notificationTableView.separatorColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func configureNotifications() {
        times = GetNotifications(calculateNotificationTimes(day.totalGlassesGoal))
        
        for index in 0..<times.count {
            let time = times[index]
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            
            let dateString = formatter.stringFromDate(time as! NSDate)
            timeStrings.addObject(dateString)
        }
    }
    
    func stateChanged(switchState: UISwitch) {
        if switchState.on {
            UpdateSettingsAttribute(Notification, key: NotificationKey, value: true)
            notificationTableView.hidden = false
            displayAddButton()
            
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(
                forTypes: [.Alert, .Badge],
                categories: Set(arrayLiteral: category)))
        } else {
            UpdateSettingsAttribute(Notification, key: NotificationKey, value: false)
            ScheduleNotifications (false);
            notificationTableView.hidden = true
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func displayAddButton() {
        let addbutton = UIBarButtonItem(
            image: UIImage(named: "add"),
            style: .Plain,
            target: self,
            action: #selector(NotificationsViewController.addNotification))
        
        navigationItem.rightBarButtonItem = addbutton
    }
    
    func addNotification() {
        createDatePickerViewWithAlertController()
    }
    
    // MARK: - Tableview Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeStrings.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = notificationTableView.dequeueReusableCellWithIdentifier(NotiticationCellId) as UITableViewCell!
        cell.textLabel?.text = timeStrings[indexPath.row] as? String
        cell.textLabel?.font = UIFont(name: "AvenirNext-regular", size: 20)!
        cell.textLabel?.textAlignment = .Center
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            times.removeObjectAtIndex(indexPath.row)
            timeStrings.removeObjectAtIndex(indexPath.row)
            SaveNotifications(times)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func createDatePickerViewWithAlertController()
    {
        let alertController = UIAlertController(title: nil, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let viewDatePicker: UIView = UIView(frame: CGRectMake(0, 0, alertController.view.frame.size.width, 200))
        viewDatePicker.backgroundColor = UIColor.clearColor()
        
        self.datePicker = UIDatePicker(frame: CGRectMake(0, 0, viewDatePicker.frame.size.width - 20, 200))
        self.datePicker.datePickerMode = UIDatePickerMode.Time
        self.datePicker.addTarget(self, action: #selector(NotificationsViewController.datePickerSelected), forControlEvents: UIControlEvents.ValueChanged)
        
        viewDatePicker.addSubview(self.datePicker)
        
        alertController.view.addSubview(viewDatePicker)
            
        let OKAction = UIAlertAction(title: "Add", style: .Default)
        { (action) in }
        alertController.addAction(OKAction)
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) { (action) in }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) { (action) in }
    }
    
    func datePickerSelected()
    {
        
    }
}
