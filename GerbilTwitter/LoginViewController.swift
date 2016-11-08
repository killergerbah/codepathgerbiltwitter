import UIKit
import BDBOAuth1Manager

final class LoginViewController: UIViewController {

    private static let tweetsSegue = "Initial"
    
    @IBOutlet weak var loginButton: UIButton!
    
    private let twitter = TwitterService()
    
    fileprivate var containerViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if twitter.loggedIn {
            self.performSegue(withIdentifier: LoginViewController.tweetsSegue, sender: self)
        } else {
            loginButton.isHidden = false
        }
    }
    
    @IBAction func onLoginButton(_ sender: AnyObject) {
        loginButton.isHidden = true
        twitter.login(
            success: { () -> Void in
                self.performSegue(withIdentifier: LoginViewController.tweetsSegue, sender: self)
            },
            failure: { (error: Error?) -> Void in
                self.loginButton.isHidden = false
            }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LoginViewController.tweetsSegue,
            let hamburgerViewController = segue.destination as? HamburgerViewController {
            
            // Ahem, can't think of a better way to do this right now.
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let menu = storyboard.instantiateViewController(withIdentifier: "Menu") as! MenuViewController
            let home = homeViewController(storyboard: storyboard)
            let profile = profileViewController(storyboard: storyboard)
            let mentions = mentionsViewController(storyboard: storyboard)
            
            hamburgerViewController.initialViewController = home

            menu.content = hamburgerViewController
            menu.items = [
                MenuItem(viewController: home, image: UIImage(named: "Home"), text: "Home"),
                MenuItem(viewController: profile, image: UIImage(named: "Me"), text: "Profile"),
                MenuItem(viewController: mentions, image: UIImage(named: "Notifications"), text: "Mentions")
            ]
            
            hamburgerViewController.menuViewController = menu
            
            containerViewController = hamburgerViewController
        }
    }
    
    private func profileViewController(storyboard: UIStoryboard) -> ContentViewController {
        let navigationController = storyboard.instantiateViewController(withIdentifier: "Profile") as! ContentViewController
        let profileViewController = navigationController.topViewController as! ProfileViewController
        profileViewController.user = twitter.currentUser!
        
        return navigationController
    }
    
    private func homeViewController(storyboard: UIStoryboard) -> ContentViewController {
        let navigationController = storyboard.instantiateViewController(withIdentifier: "Home") as! ContentViewController
        let homeViewController = navigationController.topViewController as! TweetsViewController
        homeViewController.delegate = self
        
        return navigationController
    }
    
    private func mentionsViewController(storyboard: UIStoryboard) -> ContentViewController {
        let navigationController = storyboard.instantiateViewController(withIdentifier: "Mentions") as! ContentViewController
        let mentionsViewController = navigationController.topViewController as! TweetsViewController
        mentionsViewController.delegate = self
        mentionsViewController.timelineType = TimelineType.mentions
        
        return navigationController
    }
}

extension LoginViewController: TweetsViewControllerDelegate {
    
    func tweetsViewController(_ tweetsViewController: TweetsViewController, userDidSignout user: User?) {
        tweetsViewController.dismiss(animated: true)
        containerViewController?.dismiss(animated: true)
    }
}
