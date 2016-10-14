//
//  DrinkAPI.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 2/16/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import Mixpanel

class DrinkAPI {

    typealias DrinkAPIFailure = (Error, String?) -> Void
    typealias DrinkAPISuccess = (JSON) -> Void
    
    fileprivate struct Constants {
        static let sharedInstance = DrinkAPI()
        static let baseURL = "https://webdrink.csh.rit.edu/api/index.php"
        static let imageURL = "https://csh.rit.edu/~mbillow/drink_icons/hdpi/"
    }
    
    class func testApiKey(_ apiKey: String, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        self.makeRequest(
            .GET,
            route: "test/api",
            parameters: [
                "api_key": apiKey
            ],
            completion: completion,
            failure: failure
        )
    }
    
    class func getUserInfo(_ completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        self.makeRequest(
            .GET,
            route: "users/info/",
            completion: completion,
            failure: failure
        )
    }
    
    class func dropItem(_ item: Item, delay: Int, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        Mixpanel.sharedInstance().track("Dropped Item")
        self.makeRequest(
            .POST,
            route: "drops/drop/",
            parameters: [
                "machine_id": item.machine_id,
                "slot_num": item.slot_num,
                "delay": delay
            ],
            completion: completion,
            failure: failure
        )
    }
    
    class func getMachinesStock(_ completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure?  = nil) {
        self.makeRequest(
            .GET,
            route: "machines/stock",
            completion: completion,
            failure: failure
        )
    }
    
    class func getDrops(_ uid: String? = nil, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure?  = nil) {
        let uid = uid ?? CurrentUser.sharedInstance.uid
        self.makeRequest(
            .GET,
            route: "users/drops",
            parameters: [
                "uid": uid
            ],
            completion: completion,
            failure: failure
        )
    }
    
    class func imageUrlForItem(_ item: Item) -> URL {
        return URL(string: "\(Constants.imageURL)\(item.item_id).png")!
    }
    
    class func makeRequest(_ method: Alamofire.Method, route: String, parameters: [String: AnyObject]? = nil, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        var fullParameters = parameters ?? [String: AnyObject]()
        if let apiKey = CurrentUser.getApiKey() {
            fullParameters["api_key"] = apiKey as AnyObject?
        }
        Alamofire.request(
            method,
            Constants.baseURL + "?request=" + route,
            parameters: fullParameters)
            .validate()
            .responseJSON { request, response, result in
                switch result {
                case .Success:
                    let json = JSON(result.value!)
                    if json["data"].stringValue == "false" {
                        failure?(NSError(domain: "CSH_DRINK", code: 0, userInfo: NSMutableDictionary() as [AnyHashable: Any]), json["message"].string)
                    } else {
                        completion?(json["data"])
                    }
                case .Failure(let errorData, let error):
                    if let errorData = errorData {
                        let errorJson = JSON(errorData)
                        failure?(error, errorJson["message"].string)
                    } else {
                        failure?(error, nil)
                    }
                }
            }
    }
    
    class func genericApiError(_ view: UIViewController, message: String? = nil) {
        let text = message ?? "Could not connect to drink database. Are you connected to the internet?"
        DrinkAlertView().show(view, title: "API Error", text: text, buttonText: "OK")
    }
    
}
