
import UIKit

class ContactNode: UITabBarController {
    enum Page : Int{
        case face = 0
        case recent = 1
        case message = 2
    }
    var selectedPage: Page = Page.face
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let view = viewControllers?[0] as? TabBarPageViewController, let contact = view.shortData?.contact {
            title = contact.getTitle()
        }
        selectedIndex = selectedPage.rawValue
    }
    
}
