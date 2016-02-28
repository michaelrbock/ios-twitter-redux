//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Michael Bock on 2/25/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    let refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!

    var screenName: String!
    var user: User!
    var tweets: [Tweet]! = [Tweet]()

    var isLoadingMoreData = false
    var loadingMoreView: InfiniteScrollActivityView?

    var hamburgerViewController: HamburgerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        refreshControl.addTarget(self, action: "getUserTweets", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        getUserInfo()
        getUserTweets()
    }

    func getUserInfo() {
        TwitterClient.sharedInstance.userWithScreenName(screenName) { (user, error) -> () in
            if error == nil {
                self.user = user
                self.tableView.reloadData()
            } else {
                print(error)
            }
        }
    }

    func getUserTweets() {
        TwitterClient.sharedInstance.timelineOfType("user", withParams: ["screen_name": screenName]) { (tweets, error) -> () in
            if error == nil {
                self.tweets = tweets
                self.tableView.reloadData()
            } else {
                print(error)
            }
            self.refreshControl.endRefreshing()
        }
    }

    @IBAction func onHamburgerButton(sender: UIBarButtonItem) {
        hamburgerViewController.openOrClose()
    }
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if user != nil {
                return 2
            } else {
                return 0
            }
        } else if section == 1 {
            return tweets.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let profileImageCell = tableView.dequeueReusableCellWithIdentifier("ProfileImageCell", forIndexPath: indexPath) as! ProfileImageCell
                profileImageCell.profileBannerImageView.setImageWithURL(NSURL(string: user.profileBannerImageURL!)!)
                profileImageCell.profileImageView.setImageWithURL(NSURL(string: user.profileImageURL!)!)
                profileImageCell.nameLabel.text = user.name
                profileImageCell.usernameLabel.text = "@\(user.screenName!)"
                cell = profileImageCell
            } else {
                let profileStatsCell = tableView.dequeueReusableCellWithIdentifier("ProfileStatsCell", forIndexPath: indexPath) as! ProfileStatsCell
                profileStatsCell.tweetCountLabel.text = "\(user.tweetCount!)"
                profileStatsCell.followingCountLabel.text = "\(user.followingCount!)"
                profileStatsCell.followersCountLabel.text = "\(user.followersCount!)"
                cell = profileStatsCell
            }
        } else {
            let tweetCell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
            tweetCell.tweet = tweets[indexPath.row]
            cell = tweetCell
        }

        return cell
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 4
        }
        return 0
    }

}

extension ProfileViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
