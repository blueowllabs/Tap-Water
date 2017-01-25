//
//  NotificationsViewController.swift
//  WaterUp
//
//  Created by Stephen Kyles on 8/15/15.
//  Copyright (c) 2015 Blue Owl Labs. All rights reserved.
//

import UIKit

let NotiticationCellId = "notificationCell"

func calculateNotificationTimes(_ dailyGlassGoal: Int) -> NSMutableArray {
    let numberToSchedule = dailyGlassGoal
    let notificationTimes: NSMutableArray = []
    let offset = numberToSchedule > 7 ? 1 : 2
    
    var fireDate = (Calendar.current as NSCalendar)
        .date(bySettingHour: 8, minute: 0, second: 0, of: Date(), options: [])
    
    for _ in 0..<numberToSchedule {
        notificationTimes.add(fireDate!)
        fireDate = (Calendar.current as NSCalendar)
            .date(byAdding: .hour, value: offset, to: fireDate!, options: [])
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
            style: .plain,
            target: self,
            action: #selector(NotificationsViewController.goBack))
        
        navigationItem.leftBarButtonItem = backbutton
        
        title = "Daily Notifications"
        
        configureNotifications()
        
        if GetSettingsAttribute(Notification, key: NotificationKey) {
            enableSwitch.setOn(true, animated: true)
            notificationTableView.isHidden = false
            displayAddButton()
        } else {
            enableSwitch.setOn(false, animated: true)
            notificationTableView.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }

        enableSwitch.addTarget(self, action: #selector(NotificationsViewController.stateChanged(_:)),
                               for: UIControlEvents.valueChanged)
        notificationTableView.separatorColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func configureNotifications() {
        times = GetNotifications(calculateNotificationTimes(day.totalGlassesGoal))
        
        for index in 0..<times.count {
            let time = times[index]
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            let dateString = formatter.string(from: time as! Date)
            timeStrings.add(dateString)
        }
    }
    
    func stateChanged(_ switchState: UISwitch) {
        if switchState.isOn {
            UpdateSettingsAttribute(Notification, key: NotificationKey, value: true)
            notificationTableView.isHidden = false
            displayAddButton()
            
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(
                types: [.alert, .badge],
                categories: Set(arrayLiteral: category)))
        } else {
            UpdateSettingsAttribute(Notification, key: NotificationKey, value: false)
            ScheduleNotifications (false);
            notificationTableView.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func displayAddButton() {
        let addbutton = UIBarButtonItem(
            image: UIImage(named: "add"),
            style: .plain,
            target: self,
            action: #selector(NotificationsViewController.addNotification))
        
        navigationItem.rightBarButtonItem = addbutton
    }
    
    func addNotification() {
        createDatePickerViewWithAlertController()
    }
    
    // MARK: - Tableview Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeStrings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notificationTableView.dequeueReusableCell(withIdentifier: NotiticationCellId) as UITableViewCell!
        cell?.textLabel?.text = timeStrings[indexPath.row] as? String
        cell?.textLabel?.font = UIFont(name: "AvenirNext-regular", size: 20)!
        cell?.textLabel?.textAlignment = .center
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            times.removeObject(at: indexPath.row)
            timeStrings.removeObject(at: indexPath.row)
            SaveNotifications(times)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func createDatePickerViewWithAlertController()
    {
        let alertController = UIAlertController(title: nil, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let viewDatePicker: UIView = UIView(frame: CGRect(x: 0, y: 0, width: alertController.view.frame.size.width, height: 200))
        viewDatePicker.backgroundColor = UIColor.clear
        
        self.datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: viewDatePicker.frame.size.width - 20, height: 200))
        self.datePicker.datePickerMode = UIDatePickerMode.time
        self.datePicker.addTarget(self, action: #selector(NotificationsViewController.datePickerSelected), for: UIControlEvents.valueChanged)
        
        viewDatePicker.addSubview(self.datePicker)
        
        alertController.view.addSubview(viewDatePicker)
            
        let OKAction = UIAlertAction(title: "Add", style: .default)
        { (action) in }
        alertController.addAction(OKAction)
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) { (action) in }
    }
    
    func datePickerSelected()
    {
        
    }
}
