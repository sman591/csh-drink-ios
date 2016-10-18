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
    
    class func testApiKey(apiKey: String, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        self.makeRequest(
            method: .get,
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
            method: .get,
            route: "users/info/",
            completion: completion,
            failure: failure
        )
    }
    
    class func dropItem(item: Item, delay: Int, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        Mixpanel.sharedInstance().track("Dropped Item")
        self.makeRequest(
            method: .post,
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
            method: .get,
            route: "machines/stock",
            completion: completion,
            failure: failure
        )
    }
    
    class func getDrops(uid: String? = nil, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure?  = nil) {
        let uid = uid ?? CurrentUser.sharedInstance.uid
        self.makeRequest(
            method: .get,
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
    
    class func makeRequest(method: Alamofire.HTTPMethod, route: String, parameters: Parameters? = nil, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        var fullParameters: Parameters = parameters ?? Parameters()
        if let apiKey = CurrentUser.getApiKey() {
            fullParameters["api_key"] = apiKey as AnyObject?
        }
        Alamofire.request(
            Constants.baseURL + "?request=" + route,
            method: method,
            parameters: fullParameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    if json["data"].stringValue == "false" {
                        failure?(NSError(domain: "CSH_DRINK", code: 0), json["message"].string)
                    } else {
                        completion?(json["data"])
                    }
                case .failure(let errorData):
                    failure?(errorData, "There was an error")
                }
            }
    }
    
    class func genericApiError(_ view: UIViewController, message: String? = nil) {
        let text = message ?? "Could not connect to drink database. Are you connected to the internet?"
        _ = DrinkAlertView().show(view, title: "API Error", text: text, buttonText: "OK")
    }
    
}
