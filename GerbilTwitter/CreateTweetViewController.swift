import UIKit

protocol CreateTweetViewControllerDelegate: class {
    
    func createTweetViewControllerWasCanceled(_ createTweetViewController: CreateTweetViewController)
    
    func createTweetViewControllerDidTweet(_ createTweetViewController: CreateTweetViewController)
}

final class CreateTweetViewController: UIViewController {

    fileprivate static let characterLimit = 140
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var textViewPlaceHolder: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var characterCountBarButtonItem: UIBarButtonItem!

    weak var delegate: CreateTweetViewControllerDelegate?
    
    var replyTweet: Tweet?
    
    private let twitter = TwitterService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tweetTextView.delegate = self
        
        if let user = twitter.currentUser {
            screenNameLabel.text = user.screenName
            if let profileUrl = user.profileUrl {
                userImageView.setImageWith(profileUrl)
            } else {
                userImageView.isHidden = true
            }
            
            nameLabel.text = user.name
        }

        userImageView.twitterize()
        
        if let replyTweet = replyTweet {
            navigationItem.title = "Reply"
            var recipients = [replyTweet.user.screenName]
            if let retweetScreenName = replyTweet.retweet?.user.screenName {
                recipients.append(retweetScreenName)
            }
            
            tweetTextView.text = recipients
                .map({ (screenName: String) -> String in
                    return "@\(screenName) "
                })
                .joined(separator: "")
        } else {
            navigationItem.title = ""
        }
        
        tweetTextView.becomeFirstResponder()
        characterCountBarButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 159 / 255, green: 185 / 255, blue: 1.0, alpha: 1.0)], for: UIControlState.normal)
        characterCountBarButtonItem.title = "\(CreateTweetViewController.characterLimit)"
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        delegate?.createTweetViewControllerWasCanceled(self)
    }
    
    @IBAction func onTweetButton(_ sender: AnyObject) {
        if let replyTweet = replyTweet {
            twitter.tweetBack(
                withText: tweetTextView.text,
                inReplyToTweet: replyTweet.id,
                success: { () -> Void in
                    self.delegate?.createTweetViewControllerDidTweet(self)
                },
                failure: nil
            )
        } else {
            twitter.tweet(
                withText: tweetTextView.text,
                success: { () -> Void in
                    self.delegate?.createTweetViewControllerDidTweet(self)
                },
                failure: nil
            )
        }
    }
}

extension CreateTweetViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = textView.text == ""
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = true
        characterCountBarButtonItem.title = "\(CreateTweetViewController.characterLimit - textView.text.characters.count)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= CreateTweetViewController.characterLimit
    }
}
