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

        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets

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

    func getMoreUserTweets() {
        let params = ["max_id": tweets[tweets.count-1].id!] as NSDictionary
        TwitterClient.sharedInstance.timelineOfType("user", withParams: params) { (tweets, error) -> () in
            self.tweets.appendContentsOf(tweets!)

            self.isLoadingMoreData = false
            self.loadingMoreView!.stopAnimating()

            self.tableView.reloadData()
        }
    }

    func onHamburgerButton(sender: UIBarButtonItem) {
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
                // TODO: refactor to just send user to View class.
                // TODO: protect against no banner image.
                profileImageCell.profileBannerImageView.setImageWithURL(NSURL(string: user.profileBannerImageURL!)!)
                profileImageCell.profileImageView.setImageWithURL(NSURL(string: user.profileImageURL!)!)
                profileImageCell.nameLabel.text = user.name
                profileImageCell.usernameLabel.text = "@\(user.screenName!)"
                cell = profileImageCell
            } else {

                let profileStatsCell = tableView.dequeueReusableCellWithIdentifier("ProfileStatsCell", forIndexPath: indexPath) as! ProfileStatsCell
                // TODO: refactor to just send user to View class.
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

        let detailViewController = storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        detailViewController.tweet = tweets[indexPath.row]

        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isLoadingMoreData) {
            // Calculate the position of one screen length before the bottom of the results.
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            // When the user has scrolled past the threshold, start requesting
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isLoadingMoreData = true

                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                getMoreUserTweets()
            }
        }
    }
}
