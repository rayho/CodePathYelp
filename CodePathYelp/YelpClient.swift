//
//  YelpClient.swift
//  CodePathYelp
//
//  Created by Ray Ho on 9/20/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import Foundation
import CoreLocation

let YELP: YelpClient = YelpClient()
class YelpClient {
    let BASE_URL = NSURL.URLWithString("http://api.yelp.com/v2")
    let CONSUMER_KEY = "RuPi8O7qXpXuHW01qkr9Wg"
    let CONSUMER_SECRET = "2hZfZbCu0npM1euPvvkQVA6N2rQ"
    let TOKEN = "Wn-JQe0UXv6dyJPgUQ72itiXSwrD-lWP"
    let TOKEN_SECRET = "Ld7qp9A04wE7ZQk1c_7nlO75LDU"
    var operationManager: BDBOAuth1RequestOperationManager!
    var sort: Int = 0    // 0: Best Match, 1: Distance, 2: Highest Rated
    var radius: Int = 500
    var dealsFilter: Bool = false

    init() {
        operationManager = BDBOAuth1RequestOperationManager(baseURL: BASE_URL, consumerKey: CONSUMER_KEY, consumerSecret: CONSUMER_SECRET)
        var token: BDBOAuthToken = BDBOAuthToken(token: TOKEN, secret: TOKEN_SECRET, expiration: nil)
        operationManager.requestSerializer.saveAccessToken(token)
    }

    func search(term: String, offset: Int, location: CLLocation?, success: ((operation: AFHTTPRequestOperation!, response: AnyObject!) -> ()), failure: ((operation: AFHTTPRequestOperation!, error: NSError!) -> ())) {
        var params: Dictionary = ["term": term, "offset": offset, "sort": sort, "radius": radius]

        // Add location, if available
        if (location != nil) {
            params.updateValue("\(location!.coordinate.latitude),\(location!.coordinate.longitude),\(location!.horizontalAccuracy),\(location!.altitude),\(location!.verticalAccuracy)", forKey: "ll")
        } else {
            params.updateValue("San Francisco, CA, USA", forKey: "location")
        }

        // Add deals filter, if necessary
        if (dealsFilter) {
            params.updateValue("true", forKey: "deals_filter")
        }

        // Send request
        operationManager.GET("search", parameters: params, success: success, failure: failure)
    }
}