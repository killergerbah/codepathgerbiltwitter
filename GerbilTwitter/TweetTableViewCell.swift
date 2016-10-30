//
//  TweetTableViewCell.swift
//  GerbilTwitter
//
//  Created by R-J Lim on 10/29/16.
//  Copyright © 2016 R-J Lim. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    private static let unselectedColor = UIColor.lightGray
    
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var heartCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    var tweet: Tweet? {
        didSet {
            if let tweet = tweet {
                update(withTweet: tweet)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.twitterize()
    }
    
    private func update(withTweet tweet: Tweet) {
        nameLabel.text = tweet.user.name
        screenNameLabel.text = tweet.user.screenName
        if let profileUrl = tweet.user.profileUrl {
            userImage.isHidden = false
            userImage.setImageWith(profileUrl)
        } else {
            userImage.isHidden = true
        }
        
        let heartColor = tweet.favorited ? UIColor.red : UIColor.lightGray
        heartCountLabel.textColor = heartColor
        heartImageView.tintColor = heartColor
        heartCountLabel.text = "\(tweet.favoritesCount)"
        
        let retweetColor = tweet.retweeted ? UIColor.green : UIColor.lightGray
        retweetCountLabel.textColor = retweetColor
        retweetImageView.tintColor = retweetColor
        retweetCountLabel.text = "\(tweet.retweetCount)"
        
        tweetLabel.text = tweet.text
        if let timestamp = tweet.timestamp {
            let secondsAgo = Date().timeIntervalSince1970 - timestamp.timeIntervalSince1970
            timeLabel.text = shortTime(fromSeconds: secondsAgo)
        } else {
            timeLabel.text = ""
        }
    }
    
    private func shortTime(fromSeconds seconds: TimeInterval) -> String {
        if seconds == 0 {
            return ""
        }
        
        let days = Int(seconds / 86400)
        if days > 0 {
            return "\(days)d"
        }
        
        let hours = Int(seconds / 3600)
        if hours > 0 {
            return "\(hours)h"
        }
        
        let minutes = Int(seconds / 60)
        if minutes > 0 {
            return "\(minutes)m"
        }
        
        return "\(Int(seconds))s"
    }
}
