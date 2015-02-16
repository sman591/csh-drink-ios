//
//  CurrentUser.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 2/16/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON

class CurrentUser: NSObject {

    private struct Constants {
        static let CreditsKey = "creditsKey"
    }
    
    class var sharedInstance : CurrentUser {
        struct Static {
            static let instance : CurrentUser = CurrentUser()
        }
        return Static.instance
    }
    
    var credits: Dynamic<Int>
    
    init(credits: Int = 0) {
        self.credits = Dynamic(credits)
        CurrentUser.updateUser()
    }
    
    class func isLoggedIn() -> Bool {
        return AuthenticationManager.keyIsValid()
    }
    
    class func logout() {
        AuthenticationManager.invalidateKey()
    }
    
    func setCredits(credits: Int) {
        self.credits = Dynamic(credits)
    }
    
    class func updateUser() {
        DrinkAPI.getUserInfo(completion: { json in
            self.sharedInstance.credits.value = json["credits"].intValue
        })
    }

}
