import Foundation

final class User {
    
    let name: String
    let screenName: String
    let profileUrl: URL?
    let tagline: String
    
    init(name: String, screenName: String, profileUrl: URL?, tagline: String) {
        self.name = name
        self.screenName = screenName
        self.profileUrl = profileUrl
        self.tagline = tagline
    }
}
