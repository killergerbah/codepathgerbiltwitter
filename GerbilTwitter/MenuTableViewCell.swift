import UIKit

protocol MenuTableViewCellItem: class {
    var image: UIImage? { get }
    var text: String? { get }
}

final class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!
    
    var menuItem: MenuTableViewCellItem? {
        didSet {
            menuLabel.text = menuItem?.text
            menuImageView.image = menuItem?.image
            menuImageView.tintColor = UIColor(hex: "00ccff")
        }
    }
}
