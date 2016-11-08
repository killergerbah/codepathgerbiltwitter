import Foundation

final class MentionsTimeline: Timeline {
    
    private let twitter: TwitterAdapter
    private(set) var tweets: [Tweet] = []
    
    init(twitter: TwitterAdapter) {
        self.twitter = twitter
    }
    
    
    func fetch(success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        twitter.mentionsTimeline(
            success: { (tweets: [Tweet]) -> Void in
                self.tweets = tweets
                success(tweets)
            },
            failure: failure
        )
    }
    
    func fetchMore(success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        var minId = Int.max
        for tweet in tweets {
            if tweet.id < minId {
                minId = tweet.id
            }
        }
        
        twitter.mentionsTimeline(
            olderThanId: minId - 1,
            success: { (tweets: [Tweet]) -> Void in
                self.tweets.append(contentsOf: tweets)
                success(tweets)
            },
            failure: failure
        )
    }
    
    func insert(tweet: Tweet) {
        tweets.insert(tweet, at: 0)
    }
}
