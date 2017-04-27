//
//  DPLProductRouteHandler.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 8/22/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import Foundation
import DeepLinkKit
import Mixpanel

let deepLinkUpdateKey = Notification.Name.init(rawValue: "edu.rit.csh.Drink.apiKeyUpdatedByDeepLink")

open class DPLProductRouteHandler: DPLRouteHandler {
    open override func shouldHandle(_ deepLink: DPLDeepLink!) -> Bool {
        if let apikey = deepLink.routeParameters["apikey"] as?  String  {
            CurrentUser.setApiKey(apikey)
            Mixpanel.sharedInstance().track("Got API Key via WebDrink")
            NotificationCenter.default.post(name: deepLinkUpdateKey, object: self)
            return true
        }
        return false
    }
}
