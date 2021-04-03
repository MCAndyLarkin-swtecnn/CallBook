
import UIKit

class ContactNodeTabBarController: UITabBarController{
    
    var viewModel: LocalContactViewModel = ViewModelSingle.viewModel
    
    enum Page : Int{
        case face = 0
        case recent = 1
        case message = 2
    }
    var selectedPage: Page = Page.face
    var index: IndexPath?{
        didSet{
            if let index = index{
                viewModel.initLocal(by: index.onlyCoords())
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let local = viewModel.getLocalContact(){
            title = FullName( dataSet: local).getTitle()
        }
        selectedIndex = selectedPage.rawValue
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.unbindLocal()
    }
}

