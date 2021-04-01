
import UIKit

class ContactNode: UITabBarController {
    enum Page : Int{
        case face = 0
        case recent = 1
        case message = 2
    }
    var selectedPage: Page = Page.face
    var index: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let index = self.index{
//            title = Manager.contactBook[index.section][index.row].getTitle()
//        }
        selectedIndex = selectedPage.rawValue
    }
}
