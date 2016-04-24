//
//  StatsViewController.swift
//  WaterUp
//
//  Created by Stephen Kyles on 8/15/15.
//  Copyright (c) 2015 Blue Owl Labs. All rights reserved.
//

import UIKit

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
            style: .Plain,
            target: self,
            action: "goBack")
        
        navigationItem.leftBarButtonItem = backbutton
        
        title = "Stats"
        
        average = getAverage()
        if average.isInteger {
            glassAverageLabel.text = NSString(format: "%.0f Glasses", average) as String
        } else {
            glassAverageLabel.text = NSString(format: "%.1f Glasses", average) as String
        }
    }

    override func viewDidAppear(animated: Bool) {
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
        navigationController?.popViewControllerAnimated(true)
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
        view.bringSubviewToFront(last7DyasLabel)
        view.bringSubviewToFront(graphView)
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

    func AnimateWater(amount: CGFloat) {
        let glassHeight = goalGlass.frame.height
        let numberOfPoints = day.totalGlassesGoal
        let heightOfSingleGlass = glassHeight / CGFloat(numberOfPoints)
        let waterHeight: CGFloat = CGFloat(heightOfSingleGlass * CGFloat(amount))
        
        UIView.animateWithDuration(1.0, animations: {
            self.waterView.frame.origin.y -= waterHeight
        })
    }
}
