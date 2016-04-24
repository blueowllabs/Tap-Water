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
    var startTime = 8
    
    for _ in 0..<numberToSchedule {
        notificationTimes.addObject(startTime)
        startTime = startTime + offset
    }
    
    return notificationTimes
}

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    var day: Day!
    var hours: NSMutableArray = []
    var hourStrings: NSMutableArray = []
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
            action: "goBack")
        
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

        enableSwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        notificationTableView.separatorColor = UIColor.clearColor()
        
        for index in 1...12 {
            pickerHours.addObject(index)
        }
        
        for index in 0..<60 {
            pickerMinutes.addObject(index)
        }
        
        for index in 0..<2 {
            if index == 0 {
                pickerTime.addObject("AM")
            } else {
                pickerTime.addObject("PM")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func configureNotifications() {
        hours = GetNotifications(calculateNotificationTimes(day.totalGlassesGoal))
        
        for index in 0..<hours.count {
            var hour = hours[index] as! Int
            if hour > 12 {
                hour = hour - 12
                hourStrings.addObject(NSString(format: "%i pm", hour))
            } else {
                hourStrings.addObject(NSString(format: "%i am", hour))
            }
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
            action: "addNotification")
        
        navigationItem.rightBarButtonItem = addbutton
    }
    
    func addNotification() {
        createDatePickerViewWithAlertController()
        //buildPopUp("Add Notification")
    }
    
    func buildPopUp(title: NSString) {
        shadowView = UIView (frame: view.frame)
        shadowView.backgroundColor = UIColor.blackColor()
        shadowView.alpha = 0
        view.addSubview(shadowView)
        
        let width = UIScreen.mainScreen().bounds.width / 2 + UIScreen.mainScreen().bounds.width / 4
        let labelText: NSString = title
        let lableHeight = labelText.boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-regular", size: 20)!],
            context: nil)
        
        let closeButton = UIButton(frame: CGRectMake(0, 10, width, lableHeight.height))
        closeButton.tag = 1
        closeButton.setTitle("Cancel", forState: .Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        closeButton.titleLabel?.font = UIFont(name: "AvenirNext-regular", size: 20)
        closeButton.addTarget(self, action: "dismissInfo:", forControlEvents: .TouchUpInside)

        let picker = UIPickerView(frame: CGRectMake(0, 10 + closeButton.frame.height, width, 150))
        picker.delegate = self
        picker.dataSource = self
        
        let addButton = UIButton (frame: CGRectMake(0, 10 + picker.frame.height + closeButton.frame.height, width, lableHeight.height))
        addButton.tag = 0
        addButton.setTitle(title as String, forState: .Normal)
        addButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        addButton.titleLabel?.font = UIFont(name: "AvenirNext-regular", size: 20)
        addButton.addTarget(self, action: "dismissInfo:", forControlEvents: .TouchUpInside)
        
        infoView = UIView (frame: CGRectMake(
            UIScreen.mainScreen().bounds.width / 8,
            UIScreen.mainScreen().bounds.height,
            width,
            picker.frame.height + addButton.frame.height + closeButton.frame.height))
        
        infoView.backgroundColor = UIColor.whiteColor()
        infoView.layer.cornerRadius = 10
        view.addSubview(infoView)
        
        infoView.addSubview(picker)
        infoView.addSubview(addButton)
        infoView.addSubview(closeButton)
        
        UIView.animateWithDuration(0.2, animations: {
            self.shadowView.alpha = 0.3
        })
        
        UIView.animateWithDuration(0.3, animations: {
            self.infoView.frame.origin.y -= (UIScreen.mainScreen().bounds.height / 2 + self.infoView.frame.height / 2)
        })
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerHours.count
        } else if component == 1 {
            return pickerMinutes.count
        }
        return pickerTime.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return NSString(format: "%i", pickerHours[row] as! Int) as String
        } else if component == 1 {
            let minutes = pickerMinutes[row] as! Int
            if minutes < 10 {
                return NSString(format: "0%i", pickerMinutes[row] as! Int) as String
            } else {
                return NSString(format: "%i", pickerMinutes[row] as! Int) as String
            }
        }
        return pickerTime[row] as? String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            tempHour = pickerHours[row] as! Int
        } else if component == 1 {
            tempMinute = pickerMinutes[row] as! Int
        } else {
            tempTime = pickerTime[row] as! String
        }
    }
    
    func dismissInfo(sender: UIButton) {
        if sender.tag != 1 {
            if tempTime == "AM" {
                hours.addObject(tempHour)
            } else {
                tempHour = tempHour + 12
                hours.addObject(tempHour)
            }
            
            SaveNotifications(hours)
            ScheduleNotifications(true)
            
            hours.removeAllObjects()
            hourStrings.removeAllObjects()
            
            configureNotifications()
            notificationTableView.reloadData()
        }
        
        UIView.animateWithDuration(0.2, animations: {
            self.shadowView.alpha = 0
            }, completion: {
                (value: Bool) in
                self.shadowView.removeFromSuperview()
        })
        
        UIView.animateWithDuration(0.3, animations: {
            self.infoView.frame.origin.y += (UIScreen.mainScreen().bounds.height / 2 + self.infoView.frame.height / 2)
            }, completion: {
                (value: Bool) in
                self.infoView.removeFromSuperview()
        })
    }
    
    // MARK: - Tableview Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourStrings.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = notificationTableView.dequeueReusableCellWithIdentifier(NotiticationCellId) as UITableViewCell!
        cell.textLabel?.text = hourStrings[indexPath.row] as? String
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
            hours.removeObjectAtIndex(indexPath.row)
            hourStrings.removeObjectAtIndex(indexPath.row)
            SaveNotifications(hours)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    // test
    
    func createDatePickerViewWithAlertController()
    {
        let alertController = UIAlertController(title: nil, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let viewDatePicker: UIView = UIView(frame: CGRectMake(0, 0, alertController.view.frame.size.width, 200))
        viewDatePicker.backgroundColor = UIColor.clearColor()
        
        self.datePicker = UIDatePicker(frame: CGRectMake(0, 0, viewDatePicker.frame.size.width - 20, 200))
        self.datePicker.datePickerMode = UIDatePickerMode.Time
        self.datePicker.addTarget(self, action: "datePickerSelected", forControlEvents: UIControlEvents.ValueChanged)
        
        viewDatePicker.addSubview(self.datePicker)
        
        alertController.view.addSubview(viewDatePicker)
            
        let OKAction = UIAlertAction(title: "Add", style: .Default)
        { (action) in }
        alertController.addAction(OKAction)
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) { (action) in }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) { (action) in }
    }
}
