//
//  SetGoal.swift
//  WaterUp
//
//  Created by Stephen Kyles on 9/14/15.
//  Copyright (c) 2015 Blue Owl Labs. All rights reserved.
//

import UIKit

class OnBoardingPhoneView: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    class func instanceFromNib() -> OnBoardingPhoneView {
        return UINib(nibName: "OnBoardingPhoneView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! OnBoardingPhoneView
    }
}
