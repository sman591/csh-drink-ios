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

class DrinkAPI {

    typealias DrinkAPIFailure = (NSError, String?) -> Void
    typealias DrinkAPISuccess = JSON -> Void
    
    private struct Constants {
        static let sharedInstance = DrinkAPI()
        static let baseURL = "https://webdrink.csh.rit.edu/api/index.php"
        static let imageURL = "https://csh.rit.edu/~mbillow/drink_icons/hdpi/"
    }
    
    class func testApiKey(apiKey: String, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
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
    
    class func getUserInfo(completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        self.makeRequest(
            .GET,
            route: "users/info/",
            completion: completion,
            failure: failure
        )
    }
    
    class func dropItem(item: Item, delay: Int, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
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
    
    class func getMachinesStock(completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure?  = nil) {
        self.makeRequest(
            .GET,
            route: "machines/stock",
            completion: completion,
            failure: failure
        )
    }
    
    class func getDrops(uid: String? = nil, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure?  = nil) {
        var uid = uid ?? CurrentUser.sharedInstance.uid
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
    
    class func imageUrlForItem(item: Item) -> NSURL {
        return NSURL(string: "\(Constants.imageURL)\(item.item_id).png")!
    }
    
    class func makeRequest(method: Alamofire.Method, route: String, parameters: [String: AnyObject]? = nil, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        var fullParameters = parameters ?? [String: AnyObject]()
        if let apiKey = AuthenticationManager.apiKey {
            fullParameters["api_key"] = apiKey
        }
        Alamofire.request(
            method,
            Constants.baseURL + "?request=" + route,
            parameters: fullParameters)
            .validate()
            .responseJSON { request, response, data, error in
                if let data: AnyObject = data {
                    let json = JSON(data)
                    if let error = error {
                        failure?(error, json["message"].string)
                    } else {
                        if json["data"].string == "false" {
                            failure?(NSError(), json["message"].string)
                        } else {
                            completion?(json["data"])
                        }
                    }
                } else if let error = error {
                    failure?(error, "")
                }
            }
    }
    
}