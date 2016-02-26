//
//  TweetCell.swift
//  Twitter
//
//  Created by Michael Bock on 2/20/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    var tweet: Tweet! {
        didSet {
            let user = tweet.user!
            profileImageView.setImageWithURL(NSURL(string: user.profileImageURL!)!)
            nameLabel.text = user.name!
            handleLabel.text = "@\(user.screenName!)"
            dateLabel.text = tweet.friendlyDateString()
            tweetTextLabel.text = tweet.text
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true

        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        tweetTextLabel.preferredMaxLayoutWidth = tweetTextLabel.frame.size.width
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        tweetTextLabel.preferredMaxLayoutWidth = tweetTextLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
