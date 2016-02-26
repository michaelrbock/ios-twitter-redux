//
//  Tweet.swift
//  Twitter
//
//  Created by Michael Bock on 2/18/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    let dateFormatter = NSDateFormatter()

    var id: String?
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var retweetCount: Int?
    var likeCount: Int?

    init(dictionary: NSDictionary) {
        id = dictionary["id_str"] as? String
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        retweetCount = dictionary["retweet_count"] as? Int
        likeCount = dictionary["favorite_count"] as? Int

        // TODO: make the formatter some static thing.
        dateFormatter.dateFormat = "EEE MMM  d HH:mm:ss Z y"
        createdAt = dateFormatter.dateFromString(createdAtString!)
    }

    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()

        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }

    func friendlyDateString() -> String {
        let timeSinceDate = NSDate().timeIntervalSinceDate(createdAt!)

        if timeSinceDate < (24.0 * 60.0 * 60.0) {
            let hoursSinceDate = Int(timeSinceDate / (60.0 * 60.0))
            if hoursSinceDate == 0 {
                let minutesSinceDate = Int(timeSinceDate / 60.0)
                if minutesSinceDate == 0 {
                    let secondsSinceDate = Int(timeSinceDate)
                    return "\(secondsSinceDate)s"
                } else {
                    return "\(minutesSinceDate)m"
                }
            } else {
                return "\(hoursSinceDate)h"
            }
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.stringFromDate(createdAt!)
        }
    }
}
