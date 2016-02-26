//
//  DetailViewController.swift
//  Twitter
//
//  Created by Michael Bock on 2/20/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!

    var localRetweetCount: Int!
    var localLikeCount: Int!

    var tweet: Tweet! {
        didSet {
            localRetweetCount = tweet.retweetCount ?? 0
            localLikeCount = tweet.likeCount ?? 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let user = tweet.user!
        profileImageView.setImageWithURL(NSURL(string: user.profileImageURL!)!)
        nameLabel.text = user.name
        handleLabel.text = "@\(user.screenName!)"
        tweetTextLabel.text = tweet.text
        dateLabel.text = "\(tweet.friendlyDateString()) ago"
        retweetCountLabel.text = "\(localRetweetCount) RETWEETS"
        likeCountLabel.text = "\(localLikeCount) LIKES"

        replyButton.setImage(UIImage(named: "reply.pdf"), forState: UIControlState.Normal)
        retweetButton.setImage(UIImage(named: "retweet.pdf"), forState: UIControlState.Normal)
        likeButton.setImage(UIImage(named: "like.pdf"), forState: UIControlState.Normal)

        tweetTextLabel.preferredMaxLayoutWidth = tweetTextLabel.frame.size.width
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        tweetTextLabel.preferredMaxLayoutWidth = tweetTextLabel.frame.size.width
    }

    @IBAction func onReply(sender: UIButton) {
    }

    @IBAction func onRetweet(sender: UIButton) {
        if tweet.retweetCount == localRetweetCount {
            localRetweetCount = localRetweetCount + 1
            TwitterClient.sharedInstance.retweetStatus(tweet.id!)
        } else {
            localRetweetCount = localRetweetCount - 1
        }
        retweetCountLabel.text = "\(localRetweetCount) RETWEETS"
    }

    @IBAction func onLike(sender: UIButton) {
        if tweet.likeCount == localLikeCount {
            localLikeCount = localLikeCount + 1
            TwitterClient.sharedInstance.createLikeForStatus(tweet.id!)
        } else {
            localLikeCount = localLikeCount - 1
            TwitterClient.sharedInstance.destroyLikeForStatus(tweet.id!)
        }
        likeCountLabel.text = "\(localLikeCount) LIKES"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationViewController = segue.destinationViewController as! UINavigationController
        let composeViewController = navigationViewController.topViewController as! ComposeViewController

        composeViewController.inReplyToUsername = tweet.user!.screenName
        composeViewController.inReplyToId = tweet.id
    }
}
