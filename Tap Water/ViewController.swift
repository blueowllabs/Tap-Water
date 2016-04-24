//
//  ViewController.swift
//  Tap Water
//
//  Created by Stephen Kyles on 12/11/15.
//  Copyright © 2015 Blue Owl Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var day: Day!
    var helper: UIView!
    var waterView: UIView!
    var initialView: UIView!
    
    @IBOutlet weak var goalGlass: UIImageView!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var goalHeaderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if !hasSeenOnBoarding() {
            initialView = UIView(frame: view.frame)
            initialView.backgroundColor = UIColor.whiteColor()
            navigationController!.view.addSubview(initialView)
        }
        
        ApplyTransparentNavigationBar()
        ApplyTapGesture()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "refreshView",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        
        refreshView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        
        if waterView != nil {
            waterView.removeFromSuperview()
        }
        
        if helper != nil {
            helper.removeFromSuperview()
        }
        
        if initialView != nil {
            initialView.removeFromSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshView() {
        if !hasSeenOnBoarding() {
            performSegueWithIdentifier("showOnBoarding", sender: self)
        } else {
            if waterView != nil {
                waterView.removeFromSuperview()
            }
            
            if helper != nil {
                helper.removeFromSuperview()
            }
            
            GetDayFromCoreData()
            SetupHelperView()
            SetupWaterView()
            UpdateGoalLabel()
            
            if day.totalGlassesDrank <= day.totalGlassesGoal {
                AnimateWater(day.totalGlassesDrank)
            } else {
                AnimateWater(day.totalGlassesGoal)
            }
        }
    }
    
    func ApplyTransparentNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        navigationController?.view.backgroundColor = .clearColor()
        navigationController?.navigationBar.backgroundColor = .clearColor()
        
        navigationController?.navigationBar.tintColor = .blackColor()
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "AvenirNext-regular", size: 24)!,
            NSForegroundColorAttributeName: UIColor.blackColor()
        ]
    }
    
    func ApplyTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: "AddWater")
        goalGlass.userInteractionEnabled = true
        goalGlass.addGestureRecognizer(tap)
    }
    
    func GetDayFromCoreData() {
        day = GetCurrentDay()
    }
    
    func SetupHelperView() {
        helper = UIView(
            frame: CGRectMake(
                0,
                goalGlass.bounds.height + goalGlass.frame.origin.y,
                view.frame.width,
                goalGlass.bounds.height
            ))
        
        helper.backgroundColor = .whiteColor()
        view.addSubview(helper)
        view.bringSubviewToFront(goalHeaderLabel)
        view.bringSubviewToFront(goalLabel)
    }
    
    func SetupWaterView() {
        waterView = UIView(
            frame: CGRectMake(
                goalGlass.frame.origin.x,
                goalGlass.bounds.height + goalGlass.frame.origin.y,
                goalGlass.bounds.width,
                goalGlass.bounds.height))
        waterView.backgroundColor = UIColorFromHex(0x1EA8FC)
        waterView.tag = 1
        
        view.addSubview(waterView)
        view.sendSubviewToBack(waterView)
    }
    
    func AddWater() {
        if day.totalGlassesDrank >= day.totalGlassesGoal+5 {
            let alert = UIAlertController(title: "", message: "Whoa... That's a little too much water.", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "Okay", style: .Default) { (action) in }
            alert.addAction(OKAction)
            self.presentViewController(alert, animated: true) { }
        } else {
            AddWaterToTotal(1)
        }
    }
    
    func AddWaterToTotal(amount: Int) {
        day.totalGlassesDrank! += amount
        UpdateCurrentDay(day)
        GetDayFromCoreData()
        UpdateGoalLabel()
        
        if day.totalGlassesDrank <= day.totalGlassesGoal {
            AnimateWater(1)
        }
    }
    
    func UpdateGoalLabel() {
        goalLabel.text = NSString(format: "%i / %i Glasses", day.totalGlassesDrank, day.totalGlassesGoal) as String
    }
    
    func AnimateWater(amount: Int) {
        let glassHeight = goalGlass.frame.height
        let numberOfPoints = day.totalGlassesGoal
        let heightOfSingleGlass = glassHeight / CGFloat(numberOfPoints)
        let waterHeight: CGFloat = CGFloat(heightOfSingleGlass * CGFloat(amount))
        
        if day.totalGlassesDrank != 0 {
            UIView.animateWithDuration(1.0, animations: {
                self.waterView.frame.origin.y -= waterHeight
            })
        } else {
            for view in self.view.subviews {
                if view.tag == 1 {
                    view.removeFromSuperview()
                }
            }
            SetupWaterView()
        }
    }
    
    @IBAction func SettingsButtonPressed() {
        self.performSegueWithIdentifier("settings", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settings" {
            let settingsVC = segue.destinationViewController as! SettingsViewController
            
            settingsVC.day = day
        }
    }
}

