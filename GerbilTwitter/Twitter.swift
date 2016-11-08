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
    
    func timeline(forUser userId: Int, success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?) {
        timeline(forUser: userId, olderThanId: nil, success: success, failure: failure)
    }
    
    func timeline(forUser userId: Int, olderThanId maxId: Int?, success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?) {
        var parameters: Dictionary<String, AnyObject> = [:]
        parameters["user_id"] = userId as AnyObject
        if let maxId = maxId {
            parameters["max_id"] = maxId as AnyObject
        }
        
        client.get(
            "1.1/statuses/user_timeline.json",
            parameters: parameters,
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                self.onTweetsResponse(response: response, success: success)
            },
            failure:{ (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
    
    func homeTimeline(success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?) {
        homeTimeline(olderThanId: nil, success: success, failure: failure)
    }
    
    func homeTimeline(olderThanId maxId: Int?, success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?) {
        var parameters: Dictionary<String, AnyObject> = [:]
        if let maxId = maxId {
            parameters["max_id"] = maxId as AnyObject
        }
        client.get(
            "1.1/statuses/home_timeline.json",
            parameters: parameters,
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                self.onTweetsResponse(response: response, success: success)
            },
            failure:{ (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
    
    func mentionsTimeline(success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?) {
        mentionsTimeline(olderThanId: nil, success: success, failure: failure)
    }
    
    func mentionsTimeline(olderThanId maxId: Int?, success: @escaping (([Tweet]) -> Void), failure: ((Error) -> Void)?) {
        var parameters: Dictionary<String, AnyObject> = [:]
        if let maxId = maxId {
            parameters["max_id"] = maxId as AnyObject
        }
        client.get(
            "1.1/statuses/mentions_timeline.json",
            parameters: parameters,
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                self.onTweetsResponse(response: response, success: success)
            },
            failure:{ (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
    
    private func onTweetsResponse(response: Any?, success: (([Tweet]) -> Void)) {
        let dictionaries = response as? [Dictionary<String, AnyObject>] ?? []
        let tweets = dictionaries
            .map({ (d: Dictionary<String, AnyObject>) -> Tweet? in
                Tweet(dictionary: d)
            })
            .filter { $0 != nil }
            .map { $0! }
        success(tweets)
    }
    
    private func currentAccount(success: @escaping ((User) -> Void), failure: ((Error?) -> Void)?) {
        client.get(
            "1.1/account/verify_credentials.json",
            parameters: nil,
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                if let dictionary = response as? Dictionary<String, AnyObject> {
                    if let user = User(dictionary: dictionary) {
                        success(user)
                    } else {
                        failure?(nil)
                    }
                } else {
                    failure?(nil)
                }
            },
            failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
    
    func tweet(withText text: String, success: ((Tweet) -> Void)? , failure: ((Error) -> Void)?) {
        tweet(withText: text, inReplyToTweet: nil, success: success, failure: failure)
    }
    
    func tweetBack(withText text: String, inReplyToTweet tweetId: Int, success: ((Tweet) -> Void)? , failure: ((Error) -> Void)?) {
        tweet(withText: text, inReplyToTweet: tweetId, success: success, failure: failure)
    }
    
    private func tweet(withText text: String, inReplyToTweet tweetId: Int?, success: ((Tweet) -> Void)? , failure: ((Error) -> Void)?) {
        client.post(
            "1.1/statuses/update.json",
            parameters: [
                "status": text,
                "in_reply_to_status_id": tweetId
            ],
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                if let dictionary = response as? Dictionary<String, AnyObject>,
                    let tweet = Tweet(dictionary: dictionary) {
                    success?(tweet)
                }
                
                failure?(TwitterError.failedToDeserialize)
            },
            failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
    
    func retweet(tweetId id: Int, success: ((Int) -> Void)? , failure: ((Error) -> Void)?) {
        retweet(tweetId: id, success: success, failure: failure, doing: true)
    }
    
    func myRetweetId(tweetId: Int, success: @escaping ((Int) -> Void), failure: @escaping ((Error) -> Void)) {
        client.get(
            "1.1/statuses/show.json",
            parameters: [
                "include_my_retweet": true,
                "id": tweetId
            ],
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                let retweetId = (response as? Dictionary<String, AnyObject>)?["current_user_retweet"]?["id"] as? Int ?? 0
                success(retweetId)
            },
            failure:{ (task: URLSessionDataTask?, error: Error) -> Void in
                failure(error)
            }
        )
    }
    
    func retweet(tweetId id: Int, success: ((Int) -> Void)? , failure: ((Error) -> Void)?, doing: Bool) {
        let action = doing ? "retweet" : "unretweet"
        client.post(
            "1.1/statuses/\(action)/\(id).json",
            parameters: nil,
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                let retweetCount = (response as? Dictionary<String, AnyObject>)?["retweet_count"] as? Int ?? 0
                print("\(response)")
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
    
    func lookup(user userId: Int, success: @escaping ((User) -> Void), failure: ((Error) -> Void)?) {
        client.get(
            "1.1/users/lookup.json",
            parameters: [
                "user_id": userId
            ],
            progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                if let array = response as? [Dictionary<String, AnyObject>],
                    array.count > 0,
                    let user = User(dictionary: array[0]) {
                    success(user)
                } else {
                    failure?(TwitterError.failedToDeserialize)
                }
            },
            failure:{ (task: URLSessionDataTask?, error: Error) -> Void in
                failure?(error)
            }
        )
    }
}

extension User {
    
    convenience init?(dictionary: Dictionary<String, AnyObject>) {
        guard let id = dictionary["id"] as? Int else {
            return nil
        }
        
        let name = dictionary["name"] as? String ?? ""
        let screenName = dictionary["screen_name"] as? String ?? ""
        var profileUrl: URL? = nil
        var profileBiggerUrl: URL? = nil
        if let url = dictionary["profile_image_url_https"] as? String {
            profileUrl = URL(string: url)
            let biggerUrl = url.replacingOccurrences(of: "_normal.jpg", with: "_bigger.jpg")
            profileBiggerUrl = URL(string: biggerUrl)
        }
        
        
        
        var profileBackgroundUrl: URL? = nil
        if let url = dictionary["profile_background_image_url_https"] as? String {
            profileBackgroundUrl = URL(string: url)
        }
        
        var profileBannerUrl: URL? = nil
        if let url = dictionary["profile_banner_url"] as? String {
            profileBannerUrl = URL(string: url)
        }
        
        let tagline = dictionary["description"] as? String ?? ""
        let verified = dictionary["verified"] as? Bool ?? false
        let followersCount = dictionary["followers_count"] as? Int ?? 0
        let followingCount = dictionary["friends_count"] as? Int ?? 0
        let tweetCount = dictionary["statuses_count"] as? Int ?? 0
        
        var profileTextColor: UIColor = UIColor(hex: "333333")!
        if let hexColor = dictionary["profile_text_color"] as? String,
            let color = UIColor(hex: hexColor) {
            profileTextColor = color
        }
        
        var profileLinkColor: UIColor = UIColor(hex: "1DA1F2")!
        if let hexColor = dictionary["profile_link_color"] as? String,
            let color = UIColor(hex: hexColor) {
            profileLinkColor = color
        }
        
        self.init(id: id, name: name, screenName: screenName, profileUrl: profileUrl, tagline: tagline, verified: verified, followersCount: followersCount, followingCount: followingCount, tweetCount: tweetCount, profileBackgroundUrl: profileBackgroundUrl, profileBannerUrl: profileBannerUrl, profileTextColor: profileTextColor, profileLinkColor: profileLinkColor, profileBiggerUrl: profileBiggerUrl)
    }
    
    var dictionary: Dictionary<String, AnyObject> {
        return [
            "id": id as AnyObject,
            "name": name as AnyObject,
            "screen_name": screenName as AnyObject,
            "profile_image_url_https": (profileUrl?.absoluteString ?? "") as AnyObject,
            "profile_background_image_url_https": (profileBackgroundUrl?.absoluteString ?? "") as AnyObject,
            "description": tagline as AnyObject,
            "verified": verified as AnyObject,
            "followers_count": followersCount as AnyObject,
            "friends_count": followingCount as AnyObject,
            "statuses_count": tweetCount as AnyObject
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
        guard let id = dictionary["id"] as? Int,
            let user = User(dictionary: dictionary["user"] as? Dictionary<String, AnyObject> ?? [:]) else {
            return nil
        }
        
        let text = dictionary["text"] as? String ?? ""
        let retweetCount = dictionary["retweet_count"] as? Int ?? 0
        let retweeted = dictionary["retweeted"] as? Bool ?? false
        let favoritesCount = dictionary["favorite_count"] as? Int ?? 0
        let favorited = dictionary["favorited"] as? Bool ?? false
        var timestamp: Date? = nil
        let retweet = Tweet(dictionary: dictionary["retweeted_status"] as? Dictionary<String, AnyObject> ?? [:])
        if let createdAt = dictionary["created_at"] as? String {
            timestamp = Tweet.dateFormatter.date(from: createdAt)
        }
        
        self.init(id: id, user: user, text: text, timestamp: timestamp, retweetCount: retweetCount, retweeted: retweeted, favoritesCount: favoritesCount, favorited: favorited, retweet: retweet)
    }
}

enum TwitterError: Error {
    case failedToDeserialize
}
