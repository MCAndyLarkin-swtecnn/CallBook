
import UIKit

class MessageContact: UIViewController{
    lazy var index = (tabBarController as? ContactNode)?.index
    var shortData: ShortData?{
        var data: ShortData? = nil
        if let index = self.index{
            let contact: Contact = Manager.contactBook[index.section][index.row]
            data = (contact, Manager.findAllCallsBy(numberForSearching: contact.number))
        }
        return data
    }
    
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
        if let tabBar = tabBarController as? ContactNode{
            tabBar.view.tintColor = UIColor.orange
        }
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
