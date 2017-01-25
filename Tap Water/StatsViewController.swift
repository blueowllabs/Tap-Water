//
//  StatsViewController.swift
//  WaterUp
//
//  Created by Stephen Kyles on 8/15/15.
//  Copyright (c) 2015 Blue Owl Labs. All rights reserved.
//

import UIKit
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


extension CGFloat {
    var isInteger: Bool {return rint(self) == self}
}

class StatsViewController: UIViewController {
    var day: Day!
    var helper: UIView!
    var waterView: UIView!
    var average: CGFloat!
    
    @IBOutlet weak var glassAverageLabel: UILabel!
    @IBOutlet weak var goalGlass: UIImageView!
    @IBOutlet weak var last7DyasLabel: UILabel!
    @IBOutlet weak var graphView: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backbutton = UIBarButtonItem(
            image: UIImage(named: "back"),
            style: .plain,
            target: self,
            action: #selector(StatsViewController.goBack))
        
        navigationItem.leftBarButtonItem = backbutton
        
        title = "Stats"
        
        average = getAverage()
        if average.isInteger {
            glassAverageLabel.text = NSString(format: "%.0f Glasses", average) as String
        } else {
            glassAverageLabel.text = NSString(format: "%.1f Glasses", average) as String
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        SetupHelperView()
        SetupWaterView()
        
        if average > 0 {
            if Int(average) >= day.totalGlassesGoal {
                average = CGFloat(day.totalGlassesGoal)
            }
            
            AnimateWater(average)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
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
        view.bringSubview(toFront: last7DyasLabel)
        view.bringSubview(toFront: graphView)
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

    func AnimateWater(_ amount: CGFloat) {
        let glassHeight = goalGlass.frame.height
        let numberOfPoints = day.totalGlassesGoal
        let heightOfSingleGlass = glassHeight / CGFloat(numberOfPoints!)
        let waterHeight: CGFloat = CGFloat(heightOfSingleGlass * CGFloat(amount))
        
        UIView.animate(withDuration: 1.0, animations: {
            self.waterView.frame.origin.y -= waterHeight
        })
    }
}
