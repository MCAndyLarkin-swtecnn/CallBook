
import UIKit

class MessageContact: TabBarPageViewController {
    
    @IBOutlet var messageField: UITextField!
    @IBOutlet var templateMessage1: UILabel!
    @IBOutlet var templateMessage2: UILabel!
    @IBOutlet var templateMessage3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages()
        if let tabBar = tabBarController as? ContactNode{
            tabBar.view.tintColor = UIColor.orange
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    public func loadMessages(){
        if let message = shortData?.contact.message, let history = message.history{
            //Use a test template
            //Real case -> array of real data processing
            templateMessage1.text = history[0].text
            templateMessage2.text = history[1].text
            templateMessage3.text = history[2].text
            messageField.text = message.draft
        }
    }
}
