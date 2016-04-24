//
//  CustomNavigationBar.swift
//  Swift Controls
//
//  Created by Stephen Kyles on 9/13/14.
//  Copyright (c) 2014 Blue Owl Labs. All rights reserved.
//

import Foundation
import UIKit

func UIColorFromHex(rgbValue: UInt32) -> UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:1.0)
}

func ApplyCustomNavigationBar(tintColor: UInt32, barTintColor: UInt32, barTextColor: UInt32) {
    let navigationBarAppearace = UINavigationBar.appearance()
    navigationBarAppearace.tintColor = UIColorFromHex(tintColor)
    navigationBarAppearace.barTintColor = UIColorFromHex(barTintColor)
    navigationBarAppearace.titleTextAttributes = [
        NSFontAttributeName: UIFont(name: "HelveticaNeue-light", size: 24)!,
        NSForegroundColorAttributeName: UIColorFromHex(barTextColor)
    ]
    // Uncomment for UIStatusBarStyle.LightContent and
    // add 'View controller-based status bar appearance' = N0 in info.plist
    //UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
}