import UIKit

protocol InnerContentViewControllerDelegate: class {
    
    func dismissWasRequested(_ viewController: InnerContentViewController)
}

class InnerContentViewController: UIViewController {
    
    weak var contentDelegate: InnerContentViewControllerDelegate?
}
