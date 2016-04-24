//
//  SettingsViewController.swift
//  WaterUp
//
//  Created by Stephen Kyles on 4/10/15.
//  Copyright (c) 2015 Blue Owl Labs. All rights reserved.
//

import UIKit

enum AddSubtract {
    case subtractGlass, addGlass
    case addOunce, subtractOunce
}

func calculateTotalOunces(numberOfGlasses: Int, ouncesPerGlass: Int) -> Int {
    return numberOfGlasses * ouncesPerGlass
}

class SettingsViewController: UIViewController, UIGestureRecognizerDelegate {
    var day: Day!
    var shadowView: UIView!
    var infoView: UIView!
    var totalOunces: Int = 0
    var dailyGlassGoal: Int = 0
    var ouncesPerGlass: Int = 0
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var ouncesPerGlassLabel: UILabel!
    @IBOutlet weak var totalOuncesLabel: UILabel!
    @IBOutlet weak var addOuncesButton: UIButton!
    @IBOutlet weak var subOuncesButton: UIButton!
    @IBOutlet weak var addGlassButton: UIButton!
    @IBOutlet weak var subGlassButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backbutton = UIBarButtonItem(
            image: UIImage(named: "back"),
            style: .Plain,
            target: self,
            action: "goBack")
        
        navigationItem.leftBarButtonItem = backbutton
        
        paintAddAndSubtractButtons()
        
        dailyGlassGoal = day.totalGlassesGoal
        ouncesPerGlass = day.ouncesPerGlass
        totalOunces = calculateTotalOunces(dailyGlassGoal, ouncesPerGlass: ouncesPerGlass)
        
        configureTotalOuncesLabel()
        configureDailyGlassGoalLabel()
        configureOuncesPerGlassLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func resetDailyGlass() {
        let alert = UIAlertController(
            title: "",
            message: "Are you sure? This will reset the current water level to 0.",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
        alert.addAction(cancelAction)
        
        let resetAction = UIAlertAction(title: "Reset", style: .Destructive) { (action) in
            self.day.totalGlassesDrank = 0
            self.day.todaysDate = NSDate()
            self.day.totalGlassesGoal = self.dailyGlassGoal
            self.day.ouncesPerGlass = self.ouncesPerGlass
            UpdateCurrentDay(self.day)

        }
        alert.addAction(resetAction)
        
        self.presentViewController(alert, animated: true) { }
    }
    
    @IBAction func goToNotificationsViewController() {
        performSegueWithIdentifier("showNotifications", sender: self)
    }
    
    @IBAction func goToStatsViewController() {
        performSegueWithIdentifier("showStats", sender: self)
    }
    
    @IBAction func addOrSubtractPressed(sender: UIButton) {
        switch sender.tag {
        case 0:
            if dailyGlassGoal > 1 {
                dailyGlassGoal--
                configureDailyGlassGoalLabel()
            }
            break
        case 1:
            if dailyGlassGoal < 20 {
                dailyGlassGoal++
                configureDailyGlassGoalLabel()
            }
            break
        case 2:
            if ouncesPerGlass < 64 {
                ouncesPerGlass++
                configureOuncesPerGlassLabel()
            }
            break
        case 3:
            if ouncesPerGlass > 2 {
                ouncesPerGlass--
                configureOuncesPerGlassLabel()
            }
            break
        default:
            break
        }
        
        day.totalGlassesGoal = dailyGlassGoal
        day.ouncesPerGlass = ouncesPerGlass
        UpdateCurrentDay(day)
        
        totalOunces = calculateTotalOunces(dailyGlassGoal, ouncesPerGlass: ouncesPerGlass)
        configureTotalOuncesLabel()
    }
    
    func paintAddAndSubtractButtons() {
        var addGlass = UIImage(named: "add")
        addGlass = addGlass!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        addGlassButton.setImage(addGlass, forState: .Normal)
        addGlassButton.imageView?.tintColor = UIColorFromHex(0x0496f1)
        
        var addOunce = UIImage(named: "add")
        addOunce = addOunce!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        addOuncesButton.setImage(addOunce, forState: .Normal)
        addOuncesButton.imageView?.tintColor = UIColorFromHex(0x0496f1)
        
        var subGlass = UIImage(named: "subtract")
        subGlass = subGlass!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        subGlassButton.setImage(subGlass, forState: .Normal)
        subGlassButton.imageView?.tintColor = UIColorFromHex(0x0496f1)
        
        var subOunce = UIImage(named: "subtract")
        subOunce = subOunce!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        subOuncesButton.setImage(subOunce, forState: .Normal)
        subOuncesButton.imageView?.tintColor = UIColorFromHex(0x0496f1)
    }
    
    func configureTotalOuncesLabel() {
        totalOuncesLabel.text = NSString(format: "%i oz.", totalOunces) as String
    }
    
    func configureDailyGlassGoalLabel() {
        dailyGoalLabel.text = NSString(format: "%i", dailyGlassGoal) as String
    }
    
    func configureOuncesPerGlassLabel() {
        ouncesPerGlassLabel.text = NSString(format: "%i", ouncesPerGlass) as String
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNotifications" {
            let notificationsVC = segue.destinationViewController as! NotificationsViewController
            notificationsVC.day = day
        } else if segue.identifier == "showStats" {
            let statsVC = segue.destinationViewController as! StatsViewController
            statsVC.day = day
        }
    }
}
