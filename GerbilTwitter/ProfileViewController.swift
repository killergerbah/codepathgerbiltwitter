import UIKit

protocol ProfileViewControllerDelegate: class {
    
    func profileViewControllerWasDismissed(_ viewController: ProfileViewController)
}

final class ProfileViewController: InnerContentViewController {

    @IBOutlet weak var profileTableView: UITableView!
    
    var user: User!
    
    fileprivate var lastSelected: Tweet!

    private var timelineTableViewController: TimelineTableViewController!
    
    weak var delegate: ProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = user.profileLinkColor
        title = user.name
        
        profileTableView.rowHeight = UITableViewAutomaticDimension
        profileTableView.estimatedRowHeight = 100
        
        let twitter = TwitterService()
        let timeline = UserTimeline(twitter: twitter, userId: user.id)
        timelineTableViewController = TimelineTableViewController(twitter: twitter, timeline: timeline, tweetTableView: profileTableView)
        timelineTableViewController.setup(dataSource: ProfileTableViewDataSource(user: user, timeline: timeline))
        
        timelineTableViewController.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let viewTweetViewController = navigationController.topViewController as? ViewTweetViewController {
            viewTweetViewController.delegate = self
            viewTweetViewController.tweet = lastSelected
        }
    }
    
    @IBAction func onBackButton(_ sender: AnyObject) {
        contentDelegate?.dismissWasRequested(self)
        delegate?.profileViewControllerWasDismissed(self)
    }
}

fileprivate enum Section: Int {
    case header = 0
    case timeline
}

extension ProfileViewController: TimelineTableViewControllerDelegate {
    
    func timelineTableViewController(_ controller: TimelineTableViewController, didSelectTweet tweet: Tweet) {
        lastSelected = tweet
        performSegue(withIdentifier: "ViewTweet", sender: self)
    }
}

extension ProfileViewController: ViewTweetViewControllerDelegate {
    func viewTweetViewControllerUserDidReply(_ viewTweetViewController: ViewTweetViewController, tweet: Tweet) {
        viewTweetViewController.dismiss(animated: true, completion: nil)
    }
    
    func viewTweetViewControllerUserDidDismiss(_ viewTweetViewController: ViewTweetViewController) {
        viewTweetViewController.dismiss(animated: true, completion: nil)
    }
}

private final class ProfileTableViewDataSource: NSObject, UITableViewDataSource {
    
    private unowned let user: User
    private let timeline: Timeline
    
    init(user: User, timeline: Timeline) {
        self.user = user
        self.timeline = timeline
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .header:
            return 1
        case .timeline:
            return timeline.tweets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .header:
            return profileCell(tableView: tableView)
        case .timeline:
            return tweetCell(tableView: tableView, row: indexPath.row)
        }
    }
    
    private func profileCell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Profile") as! ProfileTableViewCell
        cell.user = user
        return cell
    }
    
    private func tweetCell(tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet") as! TweetTableViewCell
        cell.tweet = timeline.tweets[row]
        return cell
    }
}
