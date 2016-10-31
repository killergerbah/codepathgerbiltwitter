import Foundation

final class TwitterService: TwitterAdapter {
    
    private static let twitter = Twitter.sharedInstance
    private static var _homeTimeline: [Tweet] = []
    
    private var twitter: Twitter {
        return TwitterService.twitter
    }
    
    var currentUser: User? {
        return twitter.currentUser
    }
    
    var loggedIn: Bool {
        return twitter.loggedIn
    }
    
    var homeTimeline: [Tweet] {
        return TwitterService._homeTimeline
    }
    
    func login(success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        twitter.login(success: success, failure: failure)
    }
    
    func logout() {
        twitter.logout()
    }
    
    func homeTimeline(success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?) {
        twitter.homeTimeline(
            success: { (tweets: [Tweet]) -> Void in
                TwitterService._homeTimeline = tweets
                success(tweets)
            },
            failure: failure
        )
    }
    
    func moreHomeTimeline(success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?) {
        var minId = Int.max
        for tweet in TwitterService._homeTimeline {
            if tweet.id < minId {
                minId = tweet.id
            }
        }
        
        twitter.homeTimeline(
            olderThanId: minId,
            success: { (tweets: [Tweet]) -> Void in
                TwitterService._homeTimeline.append(contentsOf: tweets)
                success(tweets)
            },
            failure: failure
        )
    }
    
    func tweet(withText text: String, success: (() -> Void)? , failure: ((Error) -> Void)?) {
        twitter.tweet(
            withText: text,
            success: { (tweet: Tweet) -> Void in
                TwitterService._homeTimeline.insert(tweet, at: 0)
                success?()
            },
            failure: failure
        )
    }
    
    func tweetBack(withText text: String, inReplyToTweet tweetId: Int, success: (() -> Void)? , failure: ((Error) -> Void)?) {
        twitter.tweetBack(
            withText: text,
            inReplyToTweet: tweetId,
            success: { (tweet: Tweet) -> Void in
                TwitterService._homeTimeline.insert(tweet, at: 0)
                success?()
            },
            failure: failure
        )
    }
    
    func retweet(tweet: Tweet, success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?) {
        tweet.doRetweet()
        twitter.retweet(
            tweetId: tweet.id,
            success: { (retweetCount: Int) -> Void in
                tweet.doRetweet(retweetCount: retweetCount)
                success?(tweet)
            },
            failure: { (error: Error) -> Void in
                tweet.undoRetweet()
                failure?(error, tweet)
            }
        )
    }
    
    func unretweet(tweet: Tweet, success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?) {
        twitter.myRetweetId(
            tweetId: tweet.id,
            success: { (retweetId: Int) in
                self.twitter.retweet(
                    tweetId: retweetId,
                    success: { (retweetCount: Int) -> Void in
                        tweet.undoRetweet()
                        success?(tweet)
                    },
                    failure: { (error: Error) -> Void in
                        failure?(error, tweet)
                    },
                    doing: false)
            },
            failure: { (error: Error) in
                tweet.doRetweet()
                failure?(error, tweet)
            }
        )

    }
    
    func heart(tweet: Tweet,  success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?) {
        tweet.favorite()
        twitter.heart(
            tweetId: tweet.id,
            success: { (heartCount: Int) in
                tweet.favorite(favoritesCount: heartCount)
                success?(tweet)
            },
            failure: { (error: Error) in
                tweet.unfavorite()
                failure?(error, tweet)
            }
        )
    }
    
    func unheart(tweet: Tweet,  success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?) {
        tweet.unfavorite()
        twitter.unheart(
            tweetId: tweet.id,
            success: { (heartCount: Int) -> Void in
                tweet.unfavorite(favoritesCount: heartCount)
                success?(tweet)
            },
            failure: { (error: Error) -> Void in
                tweet.favorite()
                failure?(error, tweet)
            }
        )
    }
}
