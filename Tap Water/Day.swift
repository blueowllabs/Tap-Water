//
//  Day.swift
//  WaterUp
//
//  Created by Stephen Kyles on 4/9/15.
//  Copyright (c) 2015 Blue Owl Labs. All rights reserved.
//

import UIKit

class Day: NSObject {
    var todaysDate: NSDate!
    var totalGlassesDrank: Int!
    var totalGlassesGoal: Int!
    var ouncesPerGlass: Int!
    
    init(date: NSDate, drank: Int, goal: Int, ounces: Int)
    {
        todaysDate = date
        totalGlassesDrank = drank
        totalGlassesGoal = goal
        ouncesPerGlass = ounces
    }
}
