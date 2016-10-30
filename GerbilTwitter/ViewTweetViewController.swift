import UIKit

protocol ViewTweetViewControllerDelegate: class {
    
    func viewTweetViewControllerUserDidDismiss(_ viewTweetViewController: ViewTweetViewController)
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
    
    weak var delegate: ViewTweetViewControllerDelegate?
    
    private var twitter: Twitter = Twitter.sharedInstance
    
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
    
    private func update(withTweet tweet:Tweet) {
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
        guard let tweet = tweet else {
            return
        }
        
        if tweet.favorited {
            tweet.unheart()
            twitter.unheart(
                tweetId: tweet.id,
                success: { (heartCount: Int) in
                    tweet.unheart(heartCount: heartCount)
                    self.updateHeart(withTweet: tweet)
                },
                failure: { (error: Error) in
                    tweet.heart()
                    self.updateHeart(withTweet: tweet)
                }
            )
        } else {
            tweet.heart()
            twitter.heart(
                tweetId: tweet.id,
                success: { (heartCount: Int) in
                    tweet.heart(heartCount: heartCount)
                    self.updateHeart(withTweet: tweet)
                },
                failure: { (error: Error) in
                    tweet.unheart()
                    self.updateHeart(withTweet: tweet)
                }
            )
        }
        updateHeart(withTweet: tweet)
    }
    
    @IBAction func onRetweetButton(_ sender: AnyObject) {
        guard let tweet = tweet else {
            return
        }
        if tweet.retweeted {
            tweet.unretweet()
            twitter.unretweet(
                tweetId: tweet.id,
                success: { (retweetCount: Int) in
                    tweet.unretweet(retweetCount: retweetCount)
                    self.updateRetweet(withTweet: tweet)
                },
                failure: { (error: Error) in
                    tweet.retweet()
                    self.updateRetweet(withTweet: tweet)
                }
            )
        } else {
            tweet.retweet()
            twitter.retweet(
                tweetId: tweet.id,
                success: { (retweetCount: Int) in
                    tweet.retweet(retweetCount: retweetCount)
                    self.updateRetweet(withTweet: tweet)
                },
                failure: { (error: Error) in
                    tweet.unretweet()
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
    
    func createTweetViewControllerDidTweet(_ createTweetViewController: CreateTweetViewController, withText text: String) {
        createTweetViewController.dismiss(animated: true, completion: nil)
    }
}
