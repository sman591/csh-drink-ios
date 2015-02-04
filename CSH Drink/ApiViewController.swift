//
//  ApiViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 2/4/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON

class ApiViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var apiFieldOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiFieldOutlet.becomeFirstResponder()
        apiFieldOutlet.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func submitApiKey() {
        Alamofire.request(.GET, "https://webdrink.csh.rit.edu/api/index.php?request=test/api", parameters: ["api_key": self.apiFieldOutlet.text]).responseJSON { (_, _, data, _) in
            let json = JSON(data!)
            if json["data"] == true {
                AuthenticationManager.apiKey = self.apiFieldOutlet.text;
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                self.apiFieldOutlet.becomeFirstResponder()
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        let shouldReturn = countElements(textField.text) == 16
        if shouldReturn {
            textField.resignFirstResponder()
            submitApiKey()
        }
        return shouldReturn
    }
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        let acceptableCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
//        let newLength = countElements(textField.text) + countElements(string) - range.length
//        
//        
//        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:acceptableCharacters] invertedSet];
//        
//        return (newLength <= 16) && [string rangeOfCharacterFromSet:cs].location == NSNotFound;
//    }
    
}
