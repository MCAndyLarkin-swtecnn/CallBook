
import UIKit

class ContactNode: UITabBarController {
    enum Page : Int{
        case face = 0
        case recent = 1
        case message = 2
    }
    func choose(page: Page){
        selectedIndex = page.rawValue
    }
    override func viewWillAppear(_ animated: Bool) {
        if let view = viewControllers?[0] as? TabBarPageViewController, let contact = view.shortData?.contact {
            title = contact.getTitle()
        }
    }
    
}
