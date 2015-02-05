//
//  AuthenticationManager.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 2/4/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON

private let NullAPIKey = "NULL_API_KEY"
private let APIKey = "api_key"

class AuthenticationManager: NSObject {
    
    class var apiKey: String {
        get {
            if let key = KeychainWrapper.stringForKey(APIKey) {
                return key
            } else {
                return NullAPIKey
            }
        }
        set {
            let saveSuccessful: Bool = KeychainWrapper.setString(newValue, forKey: APIKey)
        }
    }
    
    class func invalidateKey() {
        self.apiKey = NullAPIKey
    }
    
    class func keyIsValid() -> Bool {
        return self.apiKey != NullAPIKey
    }
    
}
