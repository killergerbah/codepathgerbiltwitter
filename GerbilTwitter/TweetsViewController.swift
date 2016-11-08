import UIKit

protocol TweetsViewControllerDelegate: class {
    
    func tweetsViewController(_ tweetsViewController: TweetsViewController, userDidSignout user: User?)
}

final class TweetsViewController: InnerContentViewController {
    
    @IBOutlet weak var tweetTableView: UITableView!
    
    weak var delegate: TweetsViewControllerDelegate?
    
    var timelineType: TimelineType = TimelineType.home

    fileprivate var timelineTableViewController: TimelineTableViewController!
    fileprivate var lastSelectedTweet: Tweet!
    fileprivate var lastSelectedUser: User!
    fileprivate var timeline: Timeline!

    private let twitter = TwitterService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        tweetTableView.estimatedRowHeight = 100
        
        timeline = timeline(twitter: twitter)
        timelineTableViewController = TimelineTableViewController(twitter: twitter, timeline: timeline, tweetTableView: tweetTableView)
        
        timelineTableViewController.setup(dataSource: TimelineTableViewDataSource(timeline: timeline, delegate: self, cellId: "Tweet"))
        timelineTableViewController.delegate = self
    }
    
    private func timeline(twitter: TwitterAdapter) -> Timeline {
        switch timelineType {
        case .home:
            return HomeTimeline(twitter: twitter)
        case .mentions:
            return MentionsTimeline(twitter: twitter)
        }
    }
    
    @IBAction func onBackButton(_ sender: AnyObject) {
        contentDelegate?.dismissWasRequested(self)
    }
    @IBAction func onNewTweetButton(_ sender: AnyObject) {
        performSegue(withIdentifier: Segue.createTweet.rawValue, sender: self)
    }

    @IBAction func onSignOutButton(_ sender: AnyObject) {
        let user = twitter.currentUser
        twitter.logout()
        delegate?.tweetsViewController(self, userDidSignout: user)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueId = Segue(rawValue: identifier) else {
            return
        }

        switch segueId {
        case .createTweet:
            if let navigationController = segue.destination as? UINavigationController,
                let createTweetViewController = navigationController.topViewController as? CreateTweetViewController {
                createTweetViewController.delegate = self
                createTweetViewController.timeline = timeline
            }
            break
        case .viewTweet:
            if let navigationController = segue.destination as? UINavigationController,
                let viewTweetViewController = navigationController.topViewController as? ViewTweetViewController {
                viewTweetViewController.delegate = self
                viewTweetViewController.tweet = lastSelectedTweet
            }
            break
        case .viewProfile:
            if let navigationController = segue.destination as? UINavigationController,
                let profileViewController = navigationController.topViewController as? ProfileViewController {
                profileViewController.user = lastSelectedUser
                profileViewController.delegate = self
            }
        }
    }
}

enum TimelineType {
    case home
    case mentions
}

fileprivate enum Segue: String {
    case createTweet = "CreateTweet"
    case viewTweet = "ViewTweet"
    case viewProfile = "ViewProfile"
}

extension TweetsViewController: TimelineTableViewControllerDelegate {
    
    func timelineTableViewController(_ controller: TimelineTableViewController, didSelectTweet tweet: Tweet) {
        lastSelectedTweet = tweet
        performSegue(withIdentifier: Segue.viewTweet.rawValue, sender: self)
    }
}

extension TweetsViewController: ViewTweetViewControllerDelegate {
    
    func viewTweetViewControllerUserDidDismiss(_ viewTweetViewController: ViewTweetViewController) {
        viewTweetViewController.dismiss(animated: true, completion: nil)
        tweetTableView.reloadData()
    }
    
    func viewTweetViewControllerUserDidReply(_ viewTweetViewController: ViewTweetViewController, tweet: Tweet) {
        viewTweetViewController.dismiss(animated: true, completion: nil)
        timeline.insert(tweet: tweet)
        tweetTableView.reloadData()
    }
}

extension TweetsViewController: CreateTweetViewControllerDelegate {
    
    func createTweetViewControllerWasCanceled(_ createTweetViewController: CreateTweetViewController) {
        createTweetViewController.dismiss(animated: true, completion: nil)
    }
    
    func createTweetViewControllerDidTweet(_ createTweetViewController: CreateTweetViewController, tweet: Tweet) {
        createTweetViewController.dismiss(animated: true, completion: nil)
        timeline.insert(tweet: tweet)
        tweetTableView.reloadData()
    }
}

extension TweetsViewController: TweetTableViewCellDelegate {
    
    func onProfileSelected(_ user: User) {
        lastSelectedUser = user
        performSegue(withIdentifier: Segue.viewProfile.rawValue, sender: self)
    }
}

extension TweetsViewController: ProfileViewControllerDelegate {
    
    func profileViewControllerWasDismissed(_ viewController: ProfileViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
