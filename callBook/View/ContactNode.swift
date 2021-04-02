
import UIKit

class ContactNode: UITabBarController, LocalContactViewProtocol{
    
    var viewModel: ContactNodeViewModel = ViewModelSingle.viewModel
    var localContact: ContactDataSet?
    
    enum Page : Int{
        case face = 0
        case recent = 1
        case message = 2
    }
    var selectedPage: Page = Page.face
    var index: IndexPath?{
        didSet{
            if let index = index{
                viewModel.initial(by: index.onlyCoords())
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        viewModel.uploadContactNodeData?()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        viewModel.with{ [weak self] in
            if let index = self?.index{
                self?.localContact = self?.viewModel.getLocalContact(by: index.onlyCoords())
            }
            print("Was in")
            if let local = self?.localContact{
                self?.title = FullName( dataSet: local).getTitle()
            }
        }
        selectedIndex = selectedPage.rawValue
    }
}
