//
//  CurrentUser.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 2/16/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess
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
    var uid: String
    
    init(credits: Int = 0, uid: String = "") {
        self.credits = Dynamic(credits)
        self.uid = uid
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
        DrinkAPI.getUserInfo(completion: { data in
            self.sharedInstance.credits.value = data["credits"].intValue
            self.sharedInstance.uid = data["uid"].stringValue
        })
    }

    class func canAffordItem(item: Item) -> Bool {
        return CurrentUser.sharedInstance.credits.value >= item.price
    }

}
