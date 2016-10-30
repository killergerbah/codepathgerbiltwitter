import UIKit

protocol TweetsViewControllerDelegate: class {
    
    func tweetsViewController(_ tweetsViewController: TweetsViewController, userDidSignout user: User?)
}

final class TweetsViewController: UIViewController {

    @IBOutlet weak var tweetTableView: UITableView!
    
    weak var delegate: TweetsViewControllerDelegate?
    
    fileprivate var tweets: [Tweet] = []
    fileprivate var lastSelected: Tweet!

    private let twitter = Twitter.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tweetTableView.dataSource = self
        tweetTableView.delegate = self
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        tweetTableView.estimatedRowHeight = 100
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        tweetTableView.insertSubview(refreshControl, at: 0)
        
        fetchHomeTimeline(completion: nil)
    }
    
    private func fetchHomeTimeline(completion: (() -> Void)?) {
        twitter.homeTimeline(
            success: { (tweets: [Tweet]) -> Void in
                self.tweets = tweets
                self.tweetTableView.reloadData()
                completion?()
            },
            failure: { (Error) -> Void in
                completion?()
            }
        )
    }
    
    @objc private func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchHomeTimeline { 
            refreshControl.endRefreshing()
        }
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
            }
            break
        case .viewTweet:
            if let navigationController = segue.destination as? UINavigationController,
                let viewTweetViewController = navigationController.topViewController as? ViewTweetViewController {
                viewTweetViewController.delegate = self
                viewTweetViewController.tweet = lastSelected
            }
            break
        }
    }
}

fileprivate enum Segue: String {
    case createTweet = "CreateTweetSegue"
    case viewTweet = "ViewTweetSegue"
}
extension TweetsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetTableViewCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
}

extension TweetsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        lastSelected = tweets[indexPath.row]
        performSegue(withIdentifier: Segue.viewTweet.rawValue, sender: self)
    }
}

extension TweetsViewController: ViewTweetViewControllerDelegate {
    
    func viewTweetViewControllerUserDidDismiss(_ viewTweetViewController: ViewTweetViewController) {
        viewTweetViewController.dismiss(animated: true, completion: nil)
        tweetTableView.reloadData()
    }
}

extension TweetsViewController: CreateTweetViewControllerDelegate {
    
    func createTweetViewControllerWasCanceled(_ createTweetViewController: CreateTweetViewController) {
        createTweetViewController.dismiss(animated: true, completion: nil)
    }
    
    func createTweetViewControllerDidTweet(_ createTweetViewController: CreateTweetViewController, withText text: String) {
        createTweetViewController.dismiss(animated: true, completion: nil)
    }
}
