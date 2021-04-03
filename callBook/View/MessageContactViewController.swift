
import UIKit

class MessageContactViewController: UIViewController{
    
    @IBOutlet var messageField: UITextField!
    @IBOutlet var templateMessage1: UILabel!
    @IBOutlet var templateMessage2: UILabel!
    @IBOutlet var templateMessage3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.view.tintColor = UIColor.orange
    }
    public func loadMessages(){
        
    }
}
