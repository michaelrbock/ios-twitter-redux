//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Michael Bock on 2/25/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var leadingMarginConstraint: NSLayoutConstraint!

    var originalLeadingMargin: CGFloat!

    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()  // Instantiates menuVuew so it's not nil.
            menuView.addSubview(menuViewController.view)
        }
    }

    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()

            if oldContentViewController != nil {
                oldContentViewController.willMoveToParentViewController(nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMoveToParentViewController(nil)
            }

            contentViewController.willMoveToParentViewController(self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMoveToParentViewController(self)

            closeMenu()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)

        if sender.state == UIGestureRecognizerState.Began {
            originalLeadingMargin = leadingMarginConstraint.constant
        } else if sender.state == UIGestureRecognizerState.Changed {
            leadingMarginConstraint.constant = originalLeadingMargin + translation.x
        } else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.x > 0 {  // Opening.
                openMenu()
            } else {
                closeMenu()
            }
        }
    }

    func openMenu() {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.leadingMarginConstraint.constant = self.view.frame.size.width - 50
            self.view.layoutIfNeeded()
        }
    }

    func closeMenu() {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.leadingMarginConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    func openOrClose() {
        if leadingMarginConstraint.constant != 0 {
            closeMenu()
        } else {
            openMenu()
        }
    }
}
