//
//  OnBoardingWelcomeView.swift
//  WaterUp
//
//  Created by Stephen Kyles on 10/3/15.
//  Copyright © 2015 Blue Owl Labs. All rights reserved.
//

import UIKit

class OnBoardingWelcomeView: UIView {
    @IBOutlet weak var title: UILabel!

    class func instanceFromNib() -> OnBoardingWelcomeView {
        return UINib(nibName: "OnBoardingWelcomeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! OnBoardingWelcomeView
    }
}
