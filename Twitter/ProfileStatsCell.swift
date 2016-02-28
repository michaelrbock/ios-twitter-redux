//
//  ProfileStatsCell.swift
//  Twitter
//
//  Created by Michael Bock on 2/26/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class ProfileStatsCell: UITableViewCell {

    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        tweetCountLabel.preferredMaxLayoutWidth = tweetCountLabel.frame.size.width
        followingCountLabel.preferredMaxLayoutWidth = followingCountLabel.frame.size.width
        followersCountLabel.preferredMaxLayoutWidth = followersCountLabel.frame.size.width
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        tweetCountLabel.preferredMaxLayoutWidth = tweetCountLabel.frame.size.width
        followingCountLabel.preferredMaxLayoutWidth = followingCountLabel.frame.size.width
        followersCountLabel.preferredMaxLayoutWidth = followersCountLabel.frame.size.width
    }

}
