import Foundation
import UIKit

final class HamburgerViewController: UIViewController, MenuViewControllerContent {
    
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    weak var initialViewController: ContentViewController?
    
    fileprivate var stack: [ContentViewController] = []

    private var originalContentViewLeadingConstraintConstant: CGFloat!

    var contentViewController: ContentViewController? {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if let oldContentViewController = oldContentViewController {
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.removeFromParentViewController()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            if let contentViewController = contentViewController {
                contentViewController.willMove(toParentViewController: self)
                contentView.addSubview(contentViewController.view)
                contentViewController.didMove(toParentViewController: self)
                
                if let newInner = contentViewController.topViewController as? InnerContentViewController {
                    newInner.contentDelegate = self
                }
                
                stack = stack.filter() {$0 !== contentViewController }
                stack.append(contentViewController)
            }
            
            closeMenu()
        }
    }
    
    var menuViewController: UIViewController? {
        didSet {
            view.layoutIfNeeded()
            if let menuViewController = menuViewController {
                menuView.addSubview(menuViewController.view)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentViewController = initialViewController
    }
    
    private func closeMenu() {
        UIView.animate(withDuration: 0.3) { 
            self.contentViewLeadingConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func openMenu() {
        UIView.animate(withDuration: 0.3) {
            self.contentViewLeadingConstraint.constant = 90
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        switch sender.state {
        case .began:
            originalContentViewLeadingConstraintConstant = contentViewLeadingConstraint.constant
            break
        case .changed:
            if translation.x > 0 {
                contentViewLeadingConstraint.constant = originalContentViewLeadingConstraintConstant + translation.x
            }
            break
        case .ended:
            if velocity.x > 0 {
                openMenu()
            } else {
                closeMenu()
            }
        default:
            return
        }
    }
}


extension HamburgerViewController: InnerContentViewControllerDelegate {
    
    func dismissWasRequested(_ viewController: InnerContentViewController) {
        guard stack.count > 1 else {
            return
        }
        
        stack.removeLast()
        contentViewController = stack.last
    }
}
