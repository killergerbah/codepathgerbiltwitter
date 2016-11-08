import UIKit

protocol TimelineTableViewControllerDelegate: class {
    func timelineTableViewController(_ controller: TimelineTableViewController, didSelectTweet: Tweet)
}

final class TimelineTableViewController: NSObject, UITableViewDelegate {

    private let twitter: TwitterAdapter
    private let tweetTableView: UITableView
    private let timeline: Timeline
    private var dataSource: UITableViewDataSource?
    private var loadingMore = false
    
    weak var delegate: TimelineTableViewControllerDelegate?
    
    init(twitter: TwitterAdapter, timeline: Timeline, tweetTableView: UITableView) {
        self.twitter = twitter
        self.timeline = timeline
        self.tweetTableView = tweetTableView
    }
    
    func setup(dataSource: UITableViewDataSource) {
        tweetTableView.delegate = self
        
        self.dataSource = dataSource
        tweetTableView.dataSource = dataSource
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        tweetTableView.insertSubview(refreshControl, at: 0)
        
        fetchHomeTimeline(completion: nil)
    }
    
    @objc private func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchHomeTimeline {
            refreshControl.endRefreshing()
        }
    }
    
    private func fetchHomeTimeline(completion: (() -> Void)?) {
        timeline.fetch(
            success: { (_: [Tweet]) in
                self.tweetTableView.reloadData()
                completion?()
            },
            failure: { (_: Error) in
                completion?()
            }
        )
    }
    
    fileprivate func fetchMoreHomeTimeline(completion: (() ->Void)?) {
        timeline.fetchMore(
            success: { (_: [Tweet]) in
                self.tweetTableView.reloadData()
                completion?()
            },
            failure: { (_: Error) in
                completion?()
            }
        )
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.timelineTableViewController(self, didSelectTweet: timeline.tweets[indexPath.row])

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!loadingMore && timeline.tweets.count > 0) {
            let scrollViewContentHeight = tweetTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetTableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tweetTableView.isDragging) {
                loadingMore = true
                fetchMoreHomeTimeline(completion: {
                    self.loadingMore = false
                })
            }
        }   
    }
}
