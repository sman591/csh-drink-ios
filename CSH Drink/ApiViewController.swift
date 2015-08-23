//
//  ApiViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 2/4/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import KeychainAccess
import Alamofire
import SwiftyJSON

class ApiViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var apiFieldOutlet: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBAction func openWebDrinkAction(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://webdrink.csh.rit.edu/#/settings")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiFieldOutlet.becomeFirstResponder()
        apiFieldOutlet.delegate = self
        addParallax()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func submitApiKey() {
        let apiKey = self.apiFieldOutlet.text
        self.activityIndicator.startAnimating()
        DrinkAPI.testApiKey(apiKey, completion: { data in
            if data.boolValue {
                CurrentUser.setApiKey(apiKey)
                CurrentUser.updateUser()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                var alertview = DrinkAlertView().show(self, title: "Invalid API Key", text: "Please check your key and try again.", buttonText: "OK")
                alertview.setTextTheme(.Light)
                alertview.addAction() {
                    self.apiFieldOutlet.becomeFirstResponder()
                    return
                }
            }
            self.activityIndicator.stopAnimating()
        })
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let shouldReturn = count(textField.text) == 16
        if shouldReturn {
            textField.resignFirstResponder()
            submitApiKey()
        }
        return shouldReturn
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > count(textField.text.utf16) {
            return false
        }

        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 16
    }
    
}
