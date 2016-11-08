import Foundation

protocol TwitterAdapter: class {
    
    var currentUser: User? { get }
    
    func login(success: @escaping () -> Void, failure: @escaping (Error?) -> Void)
    
    func logout()
    
    func lookup(user userId: Int, success: @escaping ((User) -> Void), failure: ((Error) -> Void)?)
    
    func homeTimeline(success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?)
    
    func homeTimeline(olderThanId id: Int, success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?)
    
    func timeline(forUser userId: Int, success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?)
    
    func timeline(forUser userId: Int, olderThanId id: Int, success: @escaping (([Tweet]) -> Void),failure: ((Error) -> Void)?)
    
    func mentionsTimeline(success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?)
    
    func mentionsTimeline(olderThanId id: Int, success: @escaping (([Tweet]) -> Void),failure: ((Error) -> Void)?)
    
    func tweet(withText text: String, success: ((Tweet) -> Void)? , failure: ((Error) -> Void)?)
    
    func tweetBack(withText text: String, inReplyToTweet tweetId: Int, success: ((Tweet) -> Void)? , failure: ((Error) -> Void)?)
    
    func retweet(tweet: Tweet, success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?)
    
    func unretweet(tweet: Tweet, success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?)
    
    func heart(tweet: Tweet,  success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?)
    
    func unheart(tweet: Tweet,  success: ((Tweet) -> Void)? , failure: ((Error, Tweet) -> Void)?)
}
