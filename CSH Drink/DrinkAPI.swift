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
    }
    
    class func getUserInfo(completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        self.makeRequest(.GET, route: "users/info/", completion: completion, failure: failure)
    }
    
    class func makeRequest(method: Alamofire.Method, route: String, parameters: [String: AnyObject]? = nil, completion: DrinkAPISuccess? = nil, failure: DrinkAPIFailure? = nil) {
        var fullParameters = parameters ?? [String: AnyObject]()
        fullParameters["api_key"] = AuthenticationManager.apiKey
        Alamofire.request(method, Constants.baseURL + "?request=" + route, parameters: fullParameters)
            .validate()
            .responseJSON { request, response, data, error in
                if let data: AnyObject = data {
                    let json = JSON(data)
                    if let error = error {
                        failure?(error, json["message"].string)
                    } else {
                        completion?(json["data"])
                    }
                }
            }
    }
    
}