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
            initialView.backgroundColor = UIColor.white
            navigationController!.view.addSubview(initialView)
        }
        
        ApplyTransparentNavigationBar()
        ApplyTapGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.refreshView),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        refreshView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIApplicationDidBecomeActive,
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
            performSegue(withIdentifier: "showOnBoarding", sender: self)
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
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.backgroundColor = .clear
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "AvenirNext-regular", size: 24)!,
            NSForegroundColorAttributeName: UIColor.black
        ]
    }
    
    func ApplyTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.AddWater))
        goalGlass.isUserInteractionEnabled = true
        goalGlass.addGestureRecognizer(tap)
    }
    
    func GetDayFromCoreData() {
        day = GetCurrentDay()
    }
    
    func SetupHelperView() {
        helper = UIView(
            frame: CGRect(
                x: 0,
                y: goalGlass.bounds.height + goalGlass.frame.origin.y,
                width: view.frame.width,
                height: goalGlass.bounds.height
            ))
        
        helper.backgroundColor = .white
        view.addSubview(helper)
        view.bringSubview(toFront: goalHeaderLabel)
        view.bringSubview(toFront: goalLabel)
    }
    
    func SetupWaterView() {
        waterView = UIView(
            frame: CGRect(
                x: goalGlass.frame.origin.x,
                y: goalGlass.bounds.height + goalGlass.frame.origin.y,
                width: goalGlass.bounds.width,
                height: goalGlass.bounds.height))
        waterView.backgroundColor = UIColorFromHex(0x1EA8FC)
        waterView.tag = 1
        
        view.addSubview(waterView)
        view.sendSubview(toBack: waterView)
    }
    
    func AddWater() {
        if day.totalGlassesDrank >= day.totalGlassesGoal+5 {
            let alert = UIAlertController(title: "", message: "Whoa... That's a little too much water.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Okay", style: .default) { (action) in }
            alert.addAction(OKAction)
            self.present(alert, animated: true) { }
        } else {
            AddWaterToTotal(1)
        }
    }
    
    func AddWaterToTotal(_ amount: Int) {
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
    
    func AnimateWater(_ amount: Int) {
        let glassHeight = goalGlass.frame.height
        let numberOfPoints = day.totalGlassesGoal
        let heightOfSingleGlass = glassHeight / CGFloat(numberOfPoints!)
        let waterHeight: CGFloat = CGFloat(heightOfSingleGlass * CGFloat(amount))
        
        if day.totalGlassesDrank != 0 {
            UIView.animate(withDuration: 1.0, animations: {
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
        self.performSegue(withIdentifier: "settings", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings" {
            let settingsVC = segue.destination as! SettingsViewController
            
            settingsVC.day = day
        }
    }
}

