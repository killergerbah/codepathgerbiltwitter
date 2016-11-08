import UIKit
import AFNetworking

final class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profileHeaderImageView: UIImageView!
    
    @IBOutlet weak var followingViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var followersViewWidth: NSLayoutConstraint!
    @IBOutlet weak var tweetsViewWidth: NSLayoutConstraint!

    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var tweetsView: UIView!
    @IBOutlet weak var followersView: UIView!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    private let twitter = TwitterService()

    var user: User? {
        didSet {
            if let user = user {
                update(withUser: user)
            }
        }
    }
    
    private func update(withUser user: User) {
        adjustWidths(constraints: [followingViewWidth, followersViewWidth, tweetsViewWidth])
        setColor(forLabels: [tweetLabel, followingLabel, followersLabel])
        setBannerImage(user: user)
        setBorders(forViews: [tweetsView, followingView, followersView])
        
        if let profileUrl = user.profileBiggerUrl {
            profileImageView.setImageWith(profileUrl)
        }
        profileImageView.twitterize()
        
        tweetLabel.text = "\(user.tweetCount)"
        followingLabel.text = "\(user.followingCount)"
        followersLabel.text = "\(user.followersCount)"
        screenNameLabel.text = "@\(user.screenName)"
        nameLabel.text = user.name
        
        twitter.lookup(user: user.id, success: { (user: User) in
            self.setBannerImage(user: user)
        },
        failure: nil)
    }
    
    private func adjustWidths(constraints: [NSLayoutConstraint]) {
        let count = CGFloat(constraints.count)
        let width = UIScreen.main.bounds.size.width / count
        for c in constraints {
            c.constant = width
        }
    }
    
    private func setBannerImage(user: User) {
        if let bannerUrl = user.profileBannerUrl {
            profileHeaderImageView.setImageWith(bannerUrl)
        } else {
            profileHeaderImageView.image = nil
            profileHeaderImageView.backgroundColor = user.profileLinkColor
        }
    }
    
    private func setBorders(forViews views: [UIView]) {
        for view in views {
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 0.25
        }
    }
    
    private func setColor(forLabels labels: [UILabel]) {
        for label in labels {
            label.textColor = user?.profileLinkColor
        }
    }
}
