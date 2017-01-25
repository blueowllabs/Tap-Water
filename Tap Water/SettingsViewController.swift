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

func calculateTotalOunces(_ numberOfGlasses: Int, ouncesPerGlass: Int) -> Int {
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
            style: .plain,
            target: self,
            action: #selector(SettingsViewController.goBack))
        
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
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetDailyGlass() {
        let alert = UIAlertController(
            title: "",
            message: "Are you sure? This will reset the current water level to 0.",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        alert.addAction(cancelAction)
        
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { (action) in
            self.day.totalGlassesDrank = 0
            self.day.todaysDate = Date()
            self.day.totalGlassesGoal = self.dailyGlassGoal
            self.day.ouncesPerGlass = self.ouncesPerGlass
            UpdateCurrentDay(self.day)

        }
        alert.addAction(resetAction)
        
        self.present(alert, animated: true) { }
    }
    
    @IBAction func goToNotificationsViewController() {
        performSegue(withIdentifier: "showNotifications", sender: self)
    }
    
    @IBAction func goToStatsViewController() {
        performSegue(withIdentifier: "showStats", sender: self)
    }
    
    @IBAction func addOrSubtractPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if dailyGlassGoal > 1 {
                dailyGlassGoal -= 1
                configureDailyGlassGoalLabel()
            }
            break
        case 1:
            if dailyGlassGoal < 20 {
                dailyGlassGoal += 1
                configureDailyGlassGoalLabel()
            }
            break
        case 2:
            if ouncesPerGlass < 64 {
                ouncesPerGlass += 1
                configureOuncesPerGlassLabel()
            }
            break
        case 3:
            if ouncesPerGlass > 2 {
                ouncesPerGlass -= 1
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
        addGlass = addGlass!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        addGlassButton.setImage(addGlass, for: UIControlState())
        addGlassButton.imageView?.tintColor = UIColorFromHex(0x0496f1)
        
        var addOunce = UIImage(named: "add")
        addOunce = addOunce!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        addOuncesButton.setImage(addOunce, for: UIControlState())
        addOuncesButton.imageView?.tintColor = UIColorFromHex(0x0496f1)
        
        var subGlass = UIImage(named: "subtract")
        subGlass = subGlass!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        subGlassButton.setImage(subGlass, for: UIControlState())
        subGlassButton.imageView?.tintColor = UIColorFromHex(0x0496f1)
        
        var subOunce = UIImage(named: "subtract")
        subOunce = subOunce!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        subOuncesButton.setImage(subOunce, for: UIControlState())
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNotifications" {
            let notificationsVC = segue.destination as! NotificationsViewController
            notificationsVC.day = day
        } else if segue.identifier == "showStats" {
            let statsVC = segue.destination as! StatsViewController
            statsVC.day = day
        }
    }
}
