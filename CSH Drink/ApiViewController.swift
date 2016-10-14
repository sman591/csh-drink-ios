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
import DeepLinkKit
import Mixpanel

class ApiViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var apiFieldOutlet: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBAction func openWebDrinkAction(_ sender: UIButton) {
        Mixpanel.sharedInstance().track("Opened WebDrink")
        UIApplication.shared.openURL(URL(string: "https://webdrink.csh.rit.edu/mobileapp/index.php")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiFieldOutlet.becomeFirstResponder()
        apiFieldOutlet.delegate = self
        addParallax()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ApiViewController.updateApiKey), name: NSNotification.Name.UIApplicationDidBecomeActive, object: UIApplication.shared)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateApiKey() {
        if (CurrentUser.getApiKey()?.isEmpty == false) {
            apiFieldOutlet.text = CurrentUser.getApiKey()
            self.view.endEditing(true)
            submitApiKey()
        }
    }
    
    func submitApiKey() {
        let apiKey = self.apiFieldOutlet.text!
        self.activityIndicator.startAnimating()
        DrinkAPI.testApiKey(apiKey,
            completion: { data in
                if data.boolValue {
                    CurrentUser.setApiKey(apiKey)
                    CurrentUser.updateUser()
                    Mixpanel.sharedInstance().track("Logged in")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    self.handleInvalidApiKey()
                }
                self.activityIndicator.stopAnimating()
            },
            failure: { errorData, message in
                self.handleInvalidApiKey()
                self.activityIndicator.stopAnimating()
            }
        )
    }
    
    func handleInvalidApiKey() {
        CurrentUser.logout()
        let alertview = DrinkAlertView().show(self, title: "Invalid API Key", text: "Please check your key and try again.", buttonText: "OK")
        alertview.setTextTheme(.light)
        alertview.addAction() {
            self.apiFieldOutlet.becomeFirstResponder()
            return
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = textField.text!.characters.count == 16
        if shouldReturn {
            textField.resignFirstResponder()
            submitApiKey()
        }
        return shouldReturn
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > textField.text!.utf16.count {
            return false
        }

        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= 16
    }
    
}
