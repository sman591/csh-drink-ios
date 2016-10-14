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
    
    @IBAction func openWebDrinkAction(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "https://webdrink.csh.rit.edu/#/settings")!)
    }
    @IBAction func openGitHubAction(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "https://github.com/sman591/csh-drink-ios")!)
    }
    @IBAction func dismissAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addParallax()
        let credits = CurrentUser.sharedInstance.credits.value
        creditsLabel.text = "\(credits) " + ("credit".pluralize(credits))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addParallax() {
        let relativeAbsoluteValue = 15
        
        // Set vertical effect
        let verticalMotionEffect =  UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -1 * relativeAbsoluteValue
        verticalMotionEffect.maximumRelativeValue = relativeAbsoluteValue
        
        // Set horizontal effect
        let horizontalMotionEffect =  UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)
        horizontalMotionEffect.minimumRelativeValue = -1 * relativeAbsoluteValue
        horizontalMotionEffect.maximumRelativeValue = relativeAbsoluteValue
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        self.backgroundImage.addMotionEffect(group)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signOut" {
            CurrentUser.logout()
        }
    }
    
}
