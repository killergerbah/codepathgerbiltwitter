import Foundation

final class Tweet {
    
    let id: Int
    let user: User
    let text: String
    let timestamp: Date?
    let retweet: Tweet?
    
    private(set) var favoritesCount: Int
    private(set) var favorited: Bool
    
    private(set) var retweetCount: Int
    private(set) var retweeted: Bool
    
    init(id: Int, user: User, text: String, timestamp: Date?, retweetCount: Int, retweeted: Bool, favoritesCount: Int, favorited: Bool, retweet: Tweet?) {
        self.id = id
        self.user = user
        self.text = text
        self.timestamp = timestamp
        self.retweetCount = retweetCount
        self.retweeted = retweeted
        self.favoritesCount = favoritesCount
        self.favorited = favorited
        self.retweet = retweet
    }
    
    func favorite(favoritesCount: Int) {
        favorited = true
        self.favoritesCount = favoritesCount
    }
    
    func favorite() {
        favorited = true
        favoritesCount += 1
    }
    
    func unfavorite(favoritesCount: Int) {
        favorited = false
        self.favoritesCount = favoritesCount
    }
    
    func unfavorite() {
        favorited = false
        favoritesCount -= 1
    }
    
    func doRetweet(retweetCount: Int) {
        retweeted = true
        self.retweetCount = retweetCount
    }
    
    func doRetweet() {
        retweeted = true
        retweetCount += 1
    }
    
    func undoRetweet(retweetCount: Int) {
        retweeted = false
        self.retweetCount = retweetCount
    }
    
    func undoRetweet() {
        retweeted = false
        retweetCount -= 1
    }
}
