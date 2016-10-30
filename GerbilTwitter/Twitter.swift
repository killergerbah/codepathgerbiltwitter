import Foundation
import BDBOAuth1Manager

final class Twitter {
    
    static let sharedInstance = Twitter()
    
    private let client = BDBOAuth1SessionManager(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "zaC2Uq5sDDsfLElGmaU1lSrdf", consumerSecret: "ftMdrA6EARpTZ1eXd8IHC8WpF7EspkLh8JPICq814rdEeb3Uov")!
    
    private var loggingIn: Bool = false
    private var loginSuccessCallbacks: [() -> ()] = []
    private var loginFailureCallbacks: [(Error?) -> ()] = []
    private var _currentUser: User? {
        didSet {
            let defaults = UserDefaults.standard
            if let newUser = _currentUser {
                let data = try! JSONSerialization.data(withJSONObject: newUser.dictionary, options: [])
                defaults.set(data, forKey: "currentUser")
            } else {
                defaults.removeObject(forKey: "currentUser")
            }
            
            defaults.synchronize()
        }
    }
    
    var loggedIn: Bool {
        return _currentUser != nil
    }
    
    var currentUser: User? {
        return _currentUser
    }
    
    private init() {
        let defaults = UserDefaults.standard
        if let serialized = defaults.object(forKey: "currentUser") as? Data,
            let dictionary = try! JSONSerialization.jsonObject(with: serialized, options: []) as? Dictionary<String, AnyObject> {
            _currentUser = User(dictionary: dictionary)
        }
    }
    
    func login(success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        if loggingIn {
            loginSuccessCallbacks.append(success)
            loginFailureCallbacks.append(failure)
            return
        }
        
        client.deauthorize()
        loggingIn = true
        client.fetchRequestToken(
            withPath: "oauth/request_token",
            method: "GET",
            callbackURL: URL(string: "gerbiltwitter://oauth"),
            scope: nil,
            success: { (requestToken: BDBOAuth1Credential?) -> Void in
                if let token = requestToken?.token {
                    let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")!
                    self.loginSuccessCallbacks.append(success)
                    self.loginFailureCallbacks.append(failure)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            },
            failure: { (error: Error?) -> Void in
                self.loggingIn = false
                failure(error)
            }
        )
    }
    
    func logout() {
        client.deauthorize()
        _currentUser = nil
    }
    
    func fetchAccessToken(withRequestToken requestToken: BDBOAuth1Credential) {
        if loggingIn {
            client.fetchAccessToken(
                withPath: "oauth/access_token",
                method: "POST",
                requestToken: requestToken,
                success: {
                    (accessToken: BDBOAuth1Credential?) -> Void in
                    self.currentAccount(
                        success: { (user: User) -> Void in
                            self._currentUser = user
                            self.onLoginSuccess()
                        },
                        failure: { (error: Error?) -> Void in
                            self.onLoginFailure(error: error)
                        }
                    )
                    
                },
                failure: { (error: Error?) -> Void in
                    self.onLoginFailure(error: error)
                }
            )
        }
    }
    
    private func onLoginSuccess() {
        loggingIn = false
        loginFailureCallbacks = []
        while self.loginSuccessCallbacks.count > 0 {
            self.loginSuccessCallbacks.removeLast()()
        }
    }
    private func onLoginFailure(error: Error?) {
        loggingIn = false
        loginSuccessCallbacks = []
        while loginFailureCallbacks.count > 0 {
            loginFailureCallbacks.removeLast()(error)
        }
    }
    
    func homeTimeline(success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?) {
        client.get(
            "1.1/statuses/home_timeline.json",
            parameters: nil,
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                let dictionaries = response as? [Dictionary<String, AnyObject>] ?? []
                let tweets = dictionaries
                    .map({ (d: Dictionary<String, AnyObject>) -> Tweet? in
                        Tweet(dictionary: d)
                    })
                    .filter { $0 != nil }
                    .map { $0! }
                success(tweets)
            },
            failure:{ (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
    
    private func currentAccount(success: @escaping ((User) -> Void), failure: ((Error?) -> Void)?) {
        client.get(
            "1.1/account/verify_credentials.json",
            parameters: nil,
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                if let dictionary = response as? Dictionary<String, AnyObject> {
                    let user = User(dictionary: dictionary)
                    success(user)
                } else {
                    failure?(nil)
                }
            },
            failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
    
    func tweet(withText text: String, success: (() -> Void)? , failure: ((Error) -> Void)?) {
        tweet(withText: text, inReplyToTweet: nil, success: success, failure: failure)
    }
    
    func tweetBack(withText text: String, inReplyToTweet tweetId: Int, success: (() -> Void)? , failure: ((Error) -> Void)?) {
        tweet(withText: text, inReplyToTweet: tweetId, success: success, failure: failure)
    }
    
    private func tweet(withText text: String, inReplyToTweet tweetId: Int?, success: (() -> Void)? , failure: ((Error) -> Void)?) {
        client.post(
            "1.1/statuses/update.json",
            parameters: ["status": text],
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                success?()
            },
            failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
    
    func retweet(tweetId id: Int, success: ((Int) -> Void)? , failure: ((Error) -> Void)?) {
        retweet(tweetId: id, success: success, failure: failure, doing: true)
    }
    
    func unretweet(tweetId id: Int, success: ((Int) -> Void)? , failure: ((Error) -> Void)?) {
        retweet(tweetId: id, success: success, failure: failure, doing: false)
    }
    
    func retweet(tweetId id: Int, success: ((Int) -> Void)? , failure: ((Error) -> Void)?, doing: Bool) {
        let action = doing ? "retweet" : "unretweet"
        client.post(
            "1.1/statuses/\(action)/\(id).json",
            parameters: nil,
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                let retweetCount = (response as? Dictionary<String, AnyObject>)?["retweet_count"] as? Int ?? 0
                success?(retweetCount)
            },
            failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
    
    func heart(tweetId id: Int,  success: ((Int) -> Void)? , failure: ((Error) -> Void)?) {
        heart(tweetId: id, success: success, failure: failure, hearting: true)
    }
    
    func unheart(tweetId id: Int,  success: ((Int) -> Void)? , failure: ((Error) -> Void)?) {
        heart(tweetId: id, success: success, failure: failure, hearting: false)
    }
    
    private func heart(tweetId id: Int,  success: ((Int) -> Void)? , failure: ((Error) -> Void)?, hearting: Bool) {
        let action = hearting ? "create" : "destroy"
        client.post(
            "1.1/favorites/\(action).json",
            parameters: ["id": id],
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                let heartCount = (response as? Dictionary<String, AnyObject>)?["favorite_count"] as? Int ?? 0
                success?(heartCount)
            },
            failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
}

extension User {
    
    convenience init(dictionary: Dictionary<String, AnyObject?>) {
        let name = dictionary["name"] as? String ?? ""
        let screenName = dictionary["screen_name"] as? String ?? ""
        var profileUrl: URL? = nil
        if let url = dictionary["profile_image_url_https"] as? String {
            profileUrl = URL(string: url)
        }
        let tagline = dictionary["description"] as? String ?? ""
        self.init(name: name, screenName: screenName, profileUrl: profileUrl, tagline: tagline)
    }
    
    var dictionary: Dictionary<String, String> {
        return [
            "name": self.name,
            "screen_name": self.screenName,
            "profile_image_url_https": self.profileUrl?.absoluteString ?? "",
            "description": self.tagline
        ]
    }
}

extension Tweet {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        return formatter
    }()
    
    convenience init?(dictionary: Dictionary<String, AnyObject>) {
        guard let id = dictionary["id"] as? Int else {
            return nil
        }
        
        let user = User(dictionary: dictionary["user"] as? Dictionary<String, AnyObject> ?? [:])
        let text = dictionary["text"] as? String ?? ""
        let retweetCount = dictionary["retweet_count"] as? Int ?? 0
        let retweeted = dictionary["retweeted"] as? Bool ?? false
        let favoritesCount = dictionary["favorite_count"] as? Int ?? 0
        let favorited = dictionary["favorited"] as? Bool ?? false
        var timestamp: Date? = nil
        if let createdAt = dictionary["created_at"] as? String {
            timestamp = Tweet.dateFormatter.date(from: createdAt)
        }
        
        self.init(id: id, user: user, text: text, timestamp: timestamp, retweetCount: retweetCount, retweeted: retweeted, favoritesCount: favoritesCount, favorited: favorited)
    }
}
