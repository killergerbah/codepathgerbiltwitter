import Foundation

protocol Timeline: class {
    
    var tweets: [Tweet] { get }
    
    func fetch(success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void)
    
    func fetchMore(success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void)
    
    func insert(tweet: Tweet)
}
