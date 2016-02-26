//
//  MenuViewController.swift
//  Twitter
//
//  Created by Michael Bock on 2/25/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var profileNavigationController: UIViewController!
    private var homeNavigationController: UIViewController!
    private var mentionsNavigationController: UIViewController!

    var viewControllers: [UIViewController] = []

    var hamburgerViewController: HamburgerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        profileNavigationController = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationController")
        homeNavigationController = storyboard.instantiateViewControllerWithIdentifier("HomeNavigationController")
        mentionsNavigationController = storyboard.instantiateViewControllerWithIdentifier("MentionsNavigationController")

        viewControllers = [profileNavigationController, homeNavigationController, mentionsNavigationController]

        hamburgerViewController.contentViewController = homeNavigationController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MenuViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell

        let titles = ["👤 Profile", "🏠 Home", "📢 Mentions"]
        cell.menuTitleLabel.text = titles[indexPath.row]

        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72.0
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }
}
