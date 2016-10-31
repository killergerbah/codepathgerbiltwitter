import UIKit
import BDBOAuth1Manager

final class LoginViewController: UIViewController {

    private static let tweetsSegue = "TweetsSegue"
    
    @IBOutlet weak var loginButton: UIButton!
    
    private let twitter = TwitterService()
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
            let navigationController = segue.destination as? UINavigationController,
            let tweetsViewController = navigationController.topViewController as? TweetsViewController {
            tweetsViewController.delegate = self
        }
    }
}

extension LoginViewController: TweetsViewControllerDelegate {
    
    func tweetsViewController(_ tweetsViewController: TweetsViewController, userDidSignout user: User?) {
        tweetsViewController.dismiss(animated: true)
    }
}
