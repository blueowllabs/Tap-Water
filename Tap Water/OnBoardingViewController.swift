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

    let bodyTextValues = ["Tap on your daily glass to add a single glass of water to it.",
        "Configure the number of glasses to drink per day and the number of ounces per glass.",
        "Recieve daily notificaitons to drink a glass of water. Use the default times or customize your own.",
        "Application badges will indicate how many glasses of water are left to reach your daily goal."]
        
    override func viewDidLoad() {
        super.viewDidLoad()

        pageDots.numberOfPages = 5
        welcomeViewConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        let goalGlass = UIImageView(frame: CGRect(x: (view.frame.width / 2) - (243 / 2),
            y: welcomeView.title.frame.origin.y + welcomeView.title.frame.height + 120 + 44 /*new label height*/, width: 243, height: 206))
        goalGlass.image = UIImage(named: "goalGlass")
        welcomeView.addSubview(goalGlass)
        
        let helper = UIView(
            frame: CGRect(
                x: 0,
                y: goalGlass.bounds.height + goalGlass.frame.origin.y,
                width: view.frame.width,
                height: goalGlass.bounds.height
            ))
        
        helper.backgroundColor = .white
        welcomeView.addSubview(helper)
        
        waterViewWelcome = UIView(
            frame: CGRect(
                x: (view.frame.width / 2) - (goalGlass.bounds.width / 2),
                y: goalGlass.bounds.height + goalGlass.frame.origin.y,
                width: goalGlass.bounds.width,
                height: goalGlass.bounds.height))
        waterViewWelcome.backgroundColor = UIColorFromHex(0x1EA8FC)
        
        welcomeView.addSubview(waterViewWelcome)
        welcomeView.sendSubview(toBack: waterViewWelcome)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OnBoardingViewController.leftWelcomeSwipe(_:)))
        leftSwipe.direction = .left
        welcomeView.addGestureRecognizer(leftSwipe)
        
        view.addSubview(welcomeView)
        view.bringSubview(toFront: pageDots)
    }
    
    func animateWelcomeView() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.welcomeView.alpha = 1
            }, completion: {
                (value: Bool) in
                
                UIView.animate(withDuration: 1.0, delay: 0, options: [], animations: {
                    self.waterViewWelcome.frame.origin.y -= self.waterViewWelcome.frame.height / 2
                    }, completion: nil )
        })
    }
    
    func leftWelcomeSwipe(_ sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.welcomeView.frame.origin.x -= self.welcomeView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 1
                self.welcomeView.removeFromSuperview()
                self.tapViewConfig()
                
                UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
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
    
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OnBoardingViewController.leftTapSwipe(_:)))
        leftSwipe.direction = .left
        tapView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OnBoardingViewController.rightTapSwipe(_:)))
        rightSwipe.direction = .right
        tapView.addGestureRecognizer(rightSwipe)
        
        view.addSubview(tapView)
        view.bringSubview(toFront: pageDots)
    }
    
    func leftTapSwipe(_ sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.tapView.frame.origin.x -= self.tapView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 2
                self.tapView.removeFromSuperview()
                self.setGoalViewConfig()
                
                UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                    self.setGoalView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    func rightTapSwipe(_ sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.tapView.frame.origin.x += self.tapView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 0
                self.tapView.removeFromSuperview()
                self.welcomeViewConfig()
                
                UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
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
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OnBoardingViewController.leftSetGoalSwipe(_:)))
        leftSwipe.direction = .left
        setGoalView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OnBoardingViewController.rightSetGoalSwipe(_:)))
        rightSwipe.direction = .right
        setGoalView.addGestureRecognizer(rightSwipe)
        
        view.addSubview(setGoalView)
        view.bringSubview(toFront: pageDots)
    }
    
    func leftSetGoalSwipe(_ sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
 
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.setGoalView.frame.origin.x -= self.setGoalView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 3
                self.setGoalView.removeFromSuperview()
                self.notifyViewConfig()
                
                UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                    self.notifyView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    func rightSetGoalSwipe(_ sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.setGoalView.frame.origin.x += self.setGoalView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 1
                self.setGoalView.removeFromSuperview()
                self.tapViewConfig()
                
                UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
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
    
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OnBoardingViewController.leftNotifySwipe(_:)))
        leftSwipe.direction = .left
        notifyView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OnBoardingViewController.rightNotifySwipe(_:)))
        rightSwipe.direction = .right
        notifyView.addGestureRecognizer(rightSwipe)
        
        view.addSubview(notifyView)
        view.bringSubview(toFront: pageDots)
    }
    
    func leftNotifySwipe(_ sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.notifyView.frame.origin.x -= self.notifyView.frame.width
            self.pageDots.alpha = 0
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 4
                self.notifyView.removeFromSuperview()
                self.badgeViewConfig()
                
                UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                    self.badgeView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    func rightNotifySwipe(_ sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.notifyView.frame.origin.x += self.notifyView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 2
                self.notifyView.removeFromSuperview()
                self.setGoalViewConfig()
                
                UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
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
        
        let getStartButton = UIButton(frame: CGRect(x: 0, y: badgeView.frame.height - 120, width: badgeView.frame.width, height: 60))
        getStartButton.setTitle("Get Started", for: UIControlState())
        getStartButton.setTitleColor(UIColor.white, for: UIControlState())
        getStartButton.titleLabel?.font = UIFont(name: "AvenirNext-bold", size: TITLE_FONT_SIZE)
        getStartButton.addTarget(self, action: #selector(OnBoardingViewController.getStartedPressed(_:)), for: .touchUpInside)
        badgeView.addSubview(getStartButton)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OnBoardingViewController.rightBadgeSwipe(_:)))
        rightSwipe.direction = .right
        badgeView.addGestureRecognizer(rightSwipe)
        
        view.addSubview(badgeView)
    }
    
    func rightBadgeSwipe(_ sender: UISwipeGestureRecognizer) {
        self.view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.badgeView.frame.origin.x += self.badgeView.frame.width
            }, completion: {
                (value: Bool) in
                
                self.pageDots.currentPage = 3
                self.badgeView.removeFromSuperview()
                self.notifyViewConfig()
                
                UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                    self.pageDots.alpha = 1
                    self.notifyView.alpha = 1
                    }, completion: {
                        (value: Bool) in
                })
        })
    }
    
    func getStartedPressed(_ sender: UIButton) {
        setOnBoarding(true)
        dismiss(animated: true, completion: nil)
    }
}
