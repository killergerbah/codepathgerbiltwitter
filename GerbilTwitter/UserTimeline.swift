import Foundation

final class UserTimeline: Timeline {
    
    private let twitter: TwitterAdapter
    private let userId: Int
    
    private(set) var tweets: [Tweet] = []
    
    init(twitter: TwitterAdapter, userId: Int) {
        self.twitter = twitter
        self.userId = userId
    }
    
    
    func fetch(success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        twitter.timeline(
            forUser: userId,
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
        
        twitter.timeline(
            forUser: userId,
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
