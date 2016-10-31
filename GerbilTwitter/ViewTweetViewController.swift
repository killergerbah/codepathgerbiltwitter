import UIKit

protocol ViewTweetViewControllerDelegate: class {
    
    func viewTweetViewControllerUserDidDismiss(_ viewTweetViewController: ViewTweetViewController)
    
    func viewTweetViewControllerUserDidReply(_ viewTweetViewController: ViewTweetViewController)
}

final class ViewTweetViewController: UIViewController {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a - dd MMM yyyy"
        return formatter
    }()
    private static let unselectedColor = UIColor.lightGray
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountEnglishLabel: UILabel!
    @IBOutlet weak var heartCountEnglishLabel: UILabel!
    @IBOutlet weak var retweetedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var retweetedLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var retweetedLabel: UILabel!
    
    weak var delegate: ViewTweetViewControllerDelegate?
    
    private var twitter: TwitterAdapter = TwitterService()
    
    var tweet: Tweet? {
        didSet(newTweet) {
            if let tweet = newTweet {
                update(withTweet: tweet)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tweet = tweet {
            update(withTweet: tweet)
        }
    }
    
    private func update(withTweet tweet: Tweet) {
        if let retweet = tweet.retweet {
            _update(withTweet: retweet)
            retweetedLabel.text = "\(tweet.user.name) Retweeted"
        } else {
            _update(withTweet: tweet)
            retweetedImageViewHeightConstraint.constant = 0
            retweetedLabelHeightConstraint.constant = 0
            retweetedLabel.isHidden = true
        }
    }
    
    private func _update(withTweet tweet: Tweet) {
        if let profileUrl = tweet.user.profileUrl {
            userImageView.setImageWith(profileUrl)
        } else {
            userImageView.isHidden = true
        }
        
        nameLabel.text = tweet.user.name
        screenNameLabel.text = tweet.user.screenName
        tweetTextLabel.text = tweet.text
        dateLabel.text = tweet.timestamp == nil ? "" : ViewTweetViewController.dateFormatter.string(from: tweet.timestamp!)
        replyButton?.imageView?.tintColor = ViewTweetViewController.unselectedColor
        updateRetweet(withTweet: tweet)
        updateHeart(withTweet: tweet)
        userImageView.twitterize()

    }
    
    private func updateRetweet(withTweet tweet: Tweet) {
        let color = tweet.retweeted ? UIColor.green : ViewTweetViewController.unselectedColor
        retweetCountLabel.text = "\(tweet.retweetCount)"
        retweetCountEnglishLabel.text = "\(tweet.retweetCount)"
        retweetCountLabel.textColor = color
        retweetButton.imageView?.tintColor = color
    }
    
    private func updateHeart(withTweet tweet: Tweet) {
        let color = tweet.favorited ? UIColor.red : ViewTweetViewController.unselectedColor
        likeCountLabel.text = "\(tweet.favoritesCount)"
        heartCountEnglishLabel.text = "\(tweet.favoritesCount)"
        likeCountLabel.textColor = color
        heartButton.imageView?.tintColor = color
    }
    
    @IBAction func onLikeButton(_ sender: AnyObject) {
        guard let tweet = tweet?.retweet ?? tweet else {
            return
        }
        
        if tweet.favorited {
            twitter.unheart(
                tweet: tweet,
                success: { (tweet: Tweet) in
                    self.updateHeart(withTweet: tweet)
                },
                failure: { (error: Error, tweet: Tweet) in
                    self.updateHeart(withTweet: tweet)
                }
            )
        } else {
            twitter.heart(
                tweet: tweet,
                success: { (tweet: Tweet) in
                    self.updateHeart(withTweet: tweet)
                },
                failure: { (error: Error, tweet: Tweet) in
                    self.updateHeart(withTweet: tweet)
                }
            )
        }
        updateHeart(withTweet: tweet)
    }
    
    @IBAction func onRetweetButton(_ sender: AnyObject) {
        guard let tweet = tweet?.retweet ?? tweet else {
            return
        }
        if tweet.retweeted {
            twitter.unretweet(
                tweet: tweet,
                success: { (tweet: Tweet) in
                    self.updateRetweet(withTweet: tweet)
                },
                failure: { (error: Error, tweet: Tweet) in
                    self.updateRetweet(withTweet: tweet)
                }
            )
        } else {
            twitter.retweet(
                tweet: tweet,
                success: { (tweet: Tweet) in
                    self.updateRetweet(withTweet: tweet)
                },
                failure: { (error: Error, tweet: Tweet) in
                    self.updateRetweet(withTweet: tweet)
                }
            )
        }
        updateRetweet(withTweet: tweet)
    }
    
    @IBAction func onReplyButton(_ sender: AnyObject) {
        performSegue(withIdentifier: "ReplySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
            let createTweetViewController = navigationController.topViewController as? CreateTweetViewController else {
                return
        }
        
        createTweetViewController.delegate = self
        createTweetViewController.replyTweet = tweet
    }
    
    @IBAction func onBackButton(_ sender: AnyObject) {
        delegate?.viewTweetViewControllerUserDidDismiss(self)
    }
}

extension ViewTweetViewController: CreateTweetViewControllerDelegate {
    
    func createTweetViewControllerWasCanceled(_ createTweetViewController: CreateTweetViewController) {
        createTweetViewController.dismiss(animated: true, completion: nil)
    }
    
    func createTweetViewControllerDidTweet(_ createTweetViewController: CreateTweetViewController) {
        createTweetViewController.dismiss(animated: true, completion: nil)
        delegate?.viewTweetViewControllerUserDidReply(self)
    }
}
