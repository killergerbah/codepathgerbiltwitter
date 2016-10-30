import Foundation

final class Tweet {
    
    let id: Int
    let user: User
    let text: String
    let timestamp: Date?
    
    private(set) var favoritesCount: Int
    private(set) var favorited: Bool
    
    private(set) var retweetCount: Int
    private(set) var retweeted: Bool
    
    init(id: Int, user: User, text: String, timestamp: Date?, retweetCount: Int, retweeted: Bool, favoritesCount: Int, favorited: Bool) {
        self.id = id
        self.user = user
        self.text = text
        self.timestamp = timestamp
        self.retweetCount = retweetCount
        self.retweeted = retweeted
        self.favoritesCount = favoritesCount
        self.favorited = favorited
    }
    
    func retweet() {
        retweetCount += 1
        retweeted = true
    }
    
    func unretweet() {
        retweetCount -= 1
        retweeted = false
    }
    
    func retweet(retweetCount: Int) {
        self.retweetCount = retweetCount
        retweeted = true
    }
    
    func unretweet(retweetCount: Int) {
        self.retweetCount = retweetCount
        retweeted = false
    }
    
    func heart() {
        favoritesCount += 1
        favorited = true
    }
    
    func heart(heartCount: Int) {
        favoritesCount = heartCount
        favorited = true
    }
    
    func unheart() {
        favoritesCount -= 1
        favorited = false
    }
    
    func unheart(heartCount: Int) {
        self.favoritesCount = heartCount
        favorited = false
    }
}
