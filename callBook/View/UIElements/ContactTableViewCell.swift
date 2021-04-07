
import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet var messageButton: MessageButton!
    @IBOutlet var signature: UILabel!
    @IBOutlet var number: UILabel!
    @IBOutlet var titleView: TitleCircleView!
    @IBOutlet var photo: UIImageView!
}
