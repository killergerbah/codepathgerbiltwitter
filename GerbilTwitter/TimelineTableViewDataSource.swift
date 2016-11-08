import UIKit

final class TimelineTableViewDataSource: NSObject, UITableViewDataSource {
    
    private let timeline: Timeline
    private let cellId: String
    private let delegate: TweetTableViewCellDelegate
    
    init(timeline: Timeline, delegate: TweetTableViewCellDelegate, cellId: String) {
        self.timeline = timeline
        self.cellId = cellId
        self.delegate = delegate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeline.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! TweetTableViewCell
        cell.tweet = timeline.tweets[indexPath.row]
        cell.delegate = delegate
        return cell
    }

}
