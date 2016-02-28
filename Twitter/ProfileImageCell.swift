//
//  ProfileImageCell.swift
//  Twitter
//
//  Created by Michael Bock on 2/26/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class ProfileImageCell: UITableViewCell {
    
    @IBOutlet weak var profileBannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
