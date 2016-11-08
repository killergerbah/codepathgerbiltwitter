import UIKit

protocol MenuViewControllerContent: class {
    
    var contentViewController: ContentViewController? { get set }
}

final class MenuViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!

    weak var content: MenuViewControllerContent?
    
    var items: [MenuItem] = []
            
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.estimatedRowHeight = 20
        menuTableView.rowHeight = UITableViewAutomaticDimension
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.reloadData()
    }
}

extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let new = items[indexPath.row].viewController
        content?.contentViewController = new
    }
}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Menu") as! MenuTableViewCell
        cell.menuItem = items[indexPath.row]
        return cell
    }
}

final class MenuItem: MenuTableViewCellItem {
    
    var viewController: ContentViewController
    var image: UIImage?
    var text: String?
    
    init(viewController: ContentViewController, image: UIImage?, text: String?) {
        self.viewController = viewController
        self.image = image
        self.text = text
    }
}
