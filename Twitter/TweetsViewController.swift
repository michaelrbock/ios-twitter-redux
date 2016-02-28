//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Michael Bock on 2/19/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import MBProgressHUD
import UIKit

enum TimelineType: String {
    case Home = "home"
    case Mentions = "mentions"
}

class TweetsViewController: UIViewController {

    let refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!

    var tweets: [Tweet]! = [Tweet]()

    var isLoadingMoreData = false
    var loadingMoreView: InfiniteScrollActivityView?

    var hamburgerViewController: HamburgerViewController!

    var timelineType: TimelineType! {
        // Sorry mom.
        didSet {
            if timelineType == TimelineType.Home {
                navigationItem.title = "Home"
            } else if timelineType == TimelineType.Mentions {
                navigationItem.title = "Mentions"
            }
            getTimelineData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        refreshControl.addTarget(self, action: "getTimelineData", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)

        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }

    func getTimelineData() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        TwitterClient.sharedInstance.timelineOfType(timelineType.rawValue, withParams: nil) { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.refreshControl.endRefreshing()
        }
    }

    func getMoreTimelineData() {
        let params = ["max_id": tweets[tweets.count-1].id!] as NSDictionary
        TwitterClient.sharedInstance.timelineOfType(timelineType.rawValue, withParams: params) { (tweets, error) -> () in
            self.tweets.appendContentsOf(tweets!)

            self.isLoadingMoreData = false
            self.loadingMoreView!.stopAnimating()

            self.tableView.reloadData()
        }
    }

    @IBAction func onHamburgerButton(sender: UIBarButtonItem) {
        hamburgerViewController.openOrClose()
    }

    func didTapProfileImage(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            print("tapped a face")
            let profileViewController = storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
            if let profileImageView = sender.view as! UIImageView? {
                profileViewController.screenName = tweets[profileImageView.tag].user?.screenName
            }
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
}

extension TweetsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell

        cell.tweet = tweets[indexPath.row]

        cell.profileImageView.tag = indexPath.row
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapProfileImage:")
        cell.profileImageView.addGestureRecognizer(tapGestureRecognizer)
        cell.profileImageView.userInteractionEnabled = true

        return cell
    }
}

extension TweetsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.selected = false

        let detailViewController = storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        detailViewController.tweet = tweets[indexPath.row]

        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension TweetsViewController: UIScrollViewDelegate {
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

                getMoreTimelineData()
            }
        }
    }
}

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }

    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }

    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .Gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }

    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.hidden = true
    }

    func startAnimating() {
        self.hidden = false
        self.activityIndicatorView.startAnimating()
    }
}
