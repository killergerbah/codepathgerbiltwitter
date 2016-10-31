import Foundation

protocol TwitterAdapter: class {
    
    var homeTimeline: [Tweet] { get }

    var currentUser: User? { get }
    
    func login(success: @escaping () -> Void, failure: @escaping (Error?) -> Void)
    
    func logout()
    
    func homeTimeline(success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?)
    
    func moreHomeTimeline(success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?)

    func tweet(withText text: String, success: (() -> Void)? , failure: ((Error) -> Void)?)
    
    func tweetBack(withText text: String, inReplyToTweet tweetId: Int, success: (() -> Void)? , failure: ((Error) -> Void)?)
    
    func retweet(tweet: Tweet, success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?)
    
    func unretweet(tweet: Tweet, success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?)
    
    func heart(tweet: Tweet,  success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?)
    
    func unheart(tweet: Tweet,  success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?)
}
