import Foundation
import UIKit

class User {
    
    let id: Int
    let name: String
    let screenName: String
    let profileUrl: URL?
    let tagline: String
    let verified: Bool
    let followersCount: Int
    let followingCount: Int
    let tweetCount: Int
    let profileBackgroundUrl: URL?
    let profileBannerUrl: URL?
    let profileTextColor: UIColor
    let profileLinkColor: UIColor
    let profileBiggerUrl: URL?
    
    init(id: Int, name: String, screenName: String, profileUrl: URL?, tagline: String, verified: Bool, followersCount: Int, followingCount: Int, tweetCount: Int, profileBackgroundUrl: URL?, profileBannerUrl: URL?, profileTextColor: UIColor, profileLinkColor: UIColor, profileBiggerUrl: URL?) {
        self.id = id
        self.name = name
        self.screenName = screenName
        self.profileUrl = profileUrl
        self.tagline = tagline
        self.verified = verified
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.tweetCount = tweetCount
        self.profileBackgroundUrl = profileBackgroundUrl
        self.profileBannerUrl = profileBannerUrl
        self.profileTextColor = profileTextColor
        self.profileLinkColor = profileLinkColor
        self.profileBiggerUrl = profileBiggerUrl
    }
}
