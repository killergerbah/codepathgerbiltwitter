import UIKit

protocol TweetTableViewCellDelegate: class {
    func onProfileSelected(_ user: User)
}

final class TweetTableViewCell: UITableViewCell {

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
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var retweetedImageView: UIImageView!
    @IBOutlet weak var retweetedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var retweetedLabelHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: TweetTableViewCellDelegate?
    
    private var retweetedLabelHeight: CGFloat!
    private var retweetedImageViewHeight: CGFloat!
    
    var tweet: Tweet? {
        didSet(oldTweet) {
            if let tweet = tweet,
                oldTweet == nil || tweet.id != oldTweet!.id {
                update(withTweet: tweet)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.twitterize()
        retweetedImageViewHeight = retweetedImageViewHeightConstraint.constant
        retweetedLabelHeight = retweetedLabelHeightConstraint.constant
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onProfileTap))
        userImage.addGestureRecognizer(tapGestureRecognizer)
        userImage.isUserInteractionEnabled = true
    }
    
    @objc private func onProfileTap(sender: UITapGestureRecognizer) {
        if let selected = tweet?.retweet ?? tweet {
            delegate?.onProfileSelected(selected.user)
        }
    }
    
    private func update(withTweet tweet: Tweet) {
        if let retweet = tweet.retweet {
            _update(withTweet: retweet)
            retweetLabel.text = "\(tweet.user.name) Retweeted"
            retweetedLabelHeightConstraint.constant = retweetedLabelHeight
            retweetedImageViewHeightConstraint.constant = retweetedImageViewHeight
        } else {
            _update(withTweet: tweet)
            retweetedLabelHeightConstraint.constant = 0
            retweetedImageViewHeightConstraint.constant = 0
        }
    }
    
    private func _update(withTweet tweet: Tweet) {
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
