//
//  AccountViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 5/25/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AccountViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var creditsLabel: UILabel!
    
    @IBAction func openWebDrinkAction(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://webdrink.csh.rit.edu/#/settings")!)
    }
    @IBAction func openGitHubAction(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/sman591/csh-drink-ios")!)
    }
    @IBAction func dismissAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addParallax()
        let credits = CurrentUser.sharedInstance.credits.value
        creditsLabel.text = "\(credits) " + ("credit".pluralize(count: credits))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addParallax() {
        let relativeAbsoluteValue = 15
        
        // Set vertical effect
        var verticalMotionEffect =  UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -1 * relativeAbsoluteValue
        verticalMotionEffect.maximumRelativeValue = relativeAbsoluteValue
        
        // Set horizontal effect
        var horizontalMotionEffect =  UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        horizontalMotionEffect.minimumRelativeValue = -1 * relativeAbsoluteValue
        horizontalMotionEffect.maximumRelativeValue = relativeAbsoluteValue
        
        // Create group to combine both
        var group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        self.backgroundImage.addMotionEffect(group)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signOut" {
            CurrentUser.logout()
        }
    }
    
}
