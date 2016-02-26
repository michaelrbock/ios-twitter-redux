//
//  TwitterClient.swift
//  Twitter
//
//  Created by Michael Bock on 2/16/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import BDBOAuth1Manager

let twitterConsumerKey = "cGnWb5AVijW7qd69lWhjqDfu4"
let twitterConsumerSecret = "p4qrER174DrSA8Ibum3ru0VvE1KohC4dG7tznqRIbthgBFCm47"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {

    var loginCompletion: ((user: User?, error: NSError?) -> ())?

    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }

        return Static.instance
    }

    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion

        // Fetch request token & redirect to autorization page.
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("got the request token")
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            }) { (error: NSError!) -> Void in
                print("failed to get request token")
                self.loginCompletion?(user: nil, error: error)
        }
    }

    func updateStatusWithParams(params: NSDictionary?) {
        POST("1.1/statuses/update.json",
            parameters: params,
            progress: nil,
            success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("tweet successfully sent")
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                print("failed to send tweet")
        }
    }

    func retweetStatus(id: String) {
        POST("1.1/statuses/retweet/\(id).json",
             parameters: nil,
             progress: nil,
             success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("retweet sent successfully for tweet id #\(id)")
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                print("there was an error sending that retweet")
        }
    }

    func createLikeForStatus(id: String) {
        POST("1.1/favorites/create.json",
            parameters: ["id": id],
            progress: nil,
            success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("like created successfully for tweet id #\(id)")
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                print("there was an error creating that like")
        }
    }

    func destroyLikeForStatus(id: String) {
        POST("1.1/favorites/destroy.json",
            parameters: ["id": id],
            progress: nil,
            success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("like destroy sent successfully for tweet id #\(id)")
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                print("there was an error destroying that like")
        }
    }

    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json",
            parameters: params,
            progress: nil,
            success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
                //print("home_timeline: \(response)")
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])

                for tweet in tweets {
                    print("text: \(tweet.text), created: \(tweet.createdAt)")
                }

                completion(tweets: tweets, error: nil)
            }, failure: { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                print("error getting home timeline")
                completion(tweets: nil, error: error)
        })
    }

    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got the access token")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)

            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json",
                parameters: nil,
                progress: nil,
                success: { (dataTast: NSURLSessionDataTask, response: AnyObject?) -> Void in
                    //print("user: \(response)")
                    let user = User(dictionary: response as! NSDictionary)
                    User.currentUser = user
                    print(user.name)
                    self.loginCompletion?(user: user, error: nil)
                }, failure: { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                    print("error getting current user")
                    self.loginCompletion?(user: nil, error: error)
            })
        }) { (error: NSError!) -> Void in
            print("Failed to receive access token")
            self.loginCompletion?(user: nil, error: error)
        }
    }
}
