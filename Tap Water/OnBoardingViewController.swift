//
//  OnBoardingViewController.swift
//  WaterUp
//
//  Created by Stephen Kyles on 7/11/15.
//  Copyright (c) 2015 Blue Owl Labs. All rights reserved.
//

import UIKit
import QuartzCore

let TITLE_FONT_SIZE: CGFloat = 24
let BODY_FONT_SIZE: CGFloat = 18

class OnBoardingViewController: UIViewController {
    @IBOutlet weak var pageDots: UIPageControl!

    let bodyTextValues = ["Simply tap on your daily glass to add a single glass of water to it.",
        "Setup the number of glasses to drink per day and the number of ounces per glass.",
        "Recieve daily notificaitons to drink a glass of water. Use the default times or customize your own.",
        "Application badges will indicate how many glasses of water are left to reach your daily goal."]
        
    override func viewDidLoad() {
        super.viewDidLoad()

        pageDots.numberOfPages = 5
        welcomeViewConfig()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        animateWelcomeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*------------------------------------
    
                WELCOME VIEW
    
    -------------------------------------*/

    var welcomeView: OnBoardingWelcomeView!
    var waterViewWelcome: UIView!
    
    func welcomeViewConfig() {
        welcomeView = OnBoardingWelcomeView.instanceFromNib()
        welcomeView.frame = view.frame
        welcomeView.alpha = 0
        
        let goalGlass = UIImageView(frame: CGRectMake((view.frame.width / 2) - (243 / 2),
            welcomeView.title.frame.origin.y + welcomeView.title.frame.height + 120 + 44 /*new label height*/, 243, 206))
        goalGlass.image = UIImage(named: "goalGlass")
        welcomeView.addSubview(goalGlass)
        
        let helper = UIView(
            frame: CGRectMake(
                0,
                goalGlass.bounds.height + goalGlass.frame.origin.y,
                view.frame.width,
                goalGlass.bounds.height
            ))
        
        helper.backgroundColor = .whiteColor()
        welcomeView.addSubview(helper)
        
        waterViewWelcome = UIView(
            frame: CGRectMake(
                (view.frame.width / 2) - (goalGlass.bounds.width / 2),
                goalGlass.bounds.height + goalGlass.frame.origin.y,
                goalGlass.bounds.width,
                goalGlass.bounds.height))
        waterViewWelcome.backgroundColor = UIColorFromHex(0x1EA8FC)
        
        welcomeView.addSubview(waterViewWelcome)
        welcomeView.sendSubviewToBack(waterViewWelcome)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: "leftWelcomeSwipe:")
        leftSwipe.direction = .Left
        welcomeView.addGestureRecognizer(leftSwipe)
        
        view.addSubview(welcomeView)
        view.bringSubviewToFront(pageDots)
    }
    
    func animateWelcomeView() {
        UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
            self.welcomeView.alpha = 1
            }, completion: {
                (value: Bool) in
                
                UIView.animateWithDuration(1.0, delay: 0, options: [], animations: {
                    self.waterViewWelcome.frame.origin.y -= self.waterViewWelcome.frame.height / 2
                    }, completion: nil )
        })
    }
    
    func leftWelcomeSwipe(sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
            self.welcomeView.frame.origin.x -= self.welcomeView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 1
                self.welcomeView.removeFromSuperview()
                self.tapViewConfig()
                
                UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                    self.tapView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    /*------------------------------------
    
                TAP VIEW
    
    -------------------------------------*/
    
    var tapView: OnBoardingPhoneView!
    
    func tapViewConfig() {
        tapView = OnBoardingPhoneView.instanceFromNib()
        tapView.frame = view.frame
        tapView.body.text = bodyTextValues[0]
        tapView.imageView.image = UIImage(named: "tapMock")
        tapView.alpha = 0
    
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: "leftTapSwipe:")
        leftSwipe.direction = .Left
        tapView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "rightTapSwipe:")
        rightSwipe.direction = .Right
        tapView.addGestureRecognizer(rightSwipe)
        
        view.addSubview(tapView)
        view.bringSubviewToFront(pageDots)
    }
    
    func leftTapSwipe(sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
            self.tapView.frame.origin.x -= self.tapView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 2
                self.tapView.removeFromSuperview()
                self.setGoalViewConfig()
                
                UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                    self.setGoalView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    func rightTapSwipe(sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
            self.tapView.frame.origin.x += self.tapView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 0
                self.tapView.removeFromSuperview()
                self.welcomeViewConfig()
                
                UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                    self.animateWelcomeView()
                    }, completion: nil)
        })
    }

    /*------------------------------------
    
               SET GOAL VIEW
    
    -------------------------------------*/
    
    var setGoalView: OnBoardingPhoneView!
    
    func setGoalViewConfig() {
        setGoalView = OnBoardingPhoneView.instanceFromNib()
        setGoalView.frame = view.frame
        setGoalView.body.text = bodyTextValues[1]
        setGoalView.imageView.image = UIImage(named: "setupMock")
        setGoalView.alpha = 0
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: "leftSetGoalSwipe:")
        leftSwipe.direction = .Left
        setGoalView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "rightSetGoalSwipe:")
        rightSwipe.direction = .Right
        setGoalView.addGestureRecognizer(rightSwipe)
        
        view.addSubview(setGoalView)
        view.bringSubviewToFront(pageDots)
    }
    
    func leftSetGoalSwipe(sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
 
        UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
            self.setGoalView.frame.origin.x -= self.setGoalView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 3
                self.setGoalView.removeFromSuperview()
                self.notifyViewConfig()
                
                UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                    self.notifyView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    func rightSetGoalSwipe(sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
            self.setGoalView.frame.origin.x += self.setGoalView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 1
                self.setGoalView.removeFromSuperview()
                self.tapViewConfig()
                
                UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                    self.tapView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    /*------------------------------------
    
                NOTIFY VIEW
    
    -------------------------------------*/
    
    var notifyView: OnBoardingPhoneView!
    
    func notifyViewConfig() {
        notifyView = OnBoardingPhoneView.instanceFromNib()
        notifyView.frame = view.frame
        notifyView.body.text = bodyTextValues[2]
        notifyView.imageView.image = UIImage(named: "notificationsMock")
        notifyView.alpha = 0
    
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: "leftNotifySwipe:")
        leftSwipe.direction = .Left
        notifyView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "rightNotifySwipe:")
        rightSwipe.direction = .Right
        notifyView.addGestureRecognizer(rightSwipe)
        
        view.addSubview(notifyView)
        view.bringSubviewToFront(pageDots)
    }
    
    func leftNotifySwipe(sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
            self.notifyView.frame.origin.x -= self.notifyView.frame.width
            self.pageDots.alpha = 0
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 4
                self.notifyView.removeFromSuperview()
                self.badgeViewConfig()
                
                UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                    self.badgeView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    func rightNotifySwipe(sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
            self.notifyView.frame.origin.x += self.notifyView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 2
                self.notifyView.removeFromSuperview()
                self.setGoalViewConfig()
                
                UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                    self.setGoalView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }

    /*------------------------------------
    
                BADGE VIEW
    
    -------------------------------------*/
    
    var badgeView: OnBoardingPhoneView!
    
    func badgeViewConfig() {
        badgeView = OnBoardingPhoneView.instanceFromNib()
        badgeView.frame = view.frame
        badgeView.body.text = bodyTextValues[3]
        badgeView.imageView.image = UIImage(named: "badgeMock")
        badgeView.alpha = 0
        
        let getStartButton = UIButton(frame: CGRectMake(0, badgeView.frame.height - 120, badgeView.frame.width, 60))
        getStartButton.setTitle("Get Started", forState: .Normal)
        getStartButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        getStartButton.titleLabel?.font = UIFont(name: "AvenirNext-bold", size: TITLE_FONT_SIZE)
        getStartButton.addTarget(self, action: "getStartedPressed:", forControlEvents: .TouchUpInside)
        badgeView.addSubview(getStartButton)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "rightBadgeSwipe:")
        rightSwipe.direction = .Right
        badgeView.addGestureRecognizer(rightSwipe)
        
        view.addSubview(badgeView)
    }
    
    func rightBadgeSwipe(sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
            self.badgeView.frame.origin.x += self.badgeView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 3
                self.badgeView.removeFromSuperview()
                self.notifyViewConfig()
                
                UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                    self.pageDots.alpha = 1
                    self.notifyView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    func getStartedPressed(sender: UIButton) {
        setOnBoarding(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
