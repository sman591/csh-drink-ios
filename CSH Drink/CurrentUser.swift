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
import Mixpanel

class CurrentUser: NSObject {

    fileprivate struct Constants {
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
    var updatedAt: Date
    var name: String
    var admin: Bool
    
    init(credits: Int = 0, uid: String = "", name: String = "", admin: Bool = false) {
        self.credits = Dynamic(credits)
        self.uid = uid
        self.updatedAt = Date()
        self.name = name
        self.admin = admin
        CurrentUser.updateUser()
    }
    
    class func isLoggedIn() -> Bool {
        return AuthenticationManager.keyIsValid()
    }
    
    class func logout() {
        Mixpanel.sharedInstance().track("Logged Out")
        AuthenticationManager.invalidateKey()
    }
    
    func setCredits(_ credits: Int) {
        self.credits = Dynamic(credits)
    }
    
    class func setApiKey(_ apiKey: String) {
        AuthenticationManager.apiKey = apiKey
    }
    
    class func getApiKey() -> String? {
        return AuthenticationManager.apiKey
    }
    
    class func updateUser() {
        DrinkAPI.getUserInfo({ data in
            self.sharedInstance.credits.value = data["credits"].intValue
            self.sharedInstance.uid = data["uid"].stringValue
            self.sharedInstance.name = data["cn"].stringValue
            self.sharedInstance.admin = data["admin"].boolValue
            self.sharedInstance.updatedAt = NSDate()
            updateUserAnalytics()
        })
    }
    
    class func updateUserAnalytics() {
        let mp = Mixpanel.sharedInstance()
        let user = CurrentUser.sharedInstance
        mp.identify(user.uid)
        mp.people.set([
            "$last_login": Date(),
            "$name": user.name,
            "credits": user.credits.value,
            "admin": user.admin
        ])
    }

    class func canAffordItem(_ item: Item) -> Bool {
        return CurrentUser.sharedInstance.credits.value >= item.price
    }

}
