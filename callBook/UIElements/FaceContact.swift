
import UIKit

class FaceContact: UIViewController{
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var number: UIButton!
    @IBOutlet var email: UIButton!
    
    lazy var index = (tabBarController as? ContactNode)?.index
    var shortData: ShortData?{
        var data: ShortData? = nil
        if let index = self.index{
            let contact: Contact = Manager.contactBook[index.section][index.row]
            data = (contact, Manager.findAllCallsBy(numberForSearching: contact.number))
        }
        return data
    }
    
    @IBAction func pressNumber(){
        guard let number = shortData?.contact.number.onlyDigits()
        else { return }
        
        if let url = URL(string: "tel://\(number)"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        Manager.addNew(callToLog: Call(abonent: number, io: .outputFail))
    }
    
    @IBAction func changeContact(_ sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Change the contact", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            if let name = self.shortData?.contact.name{
                textField.text = name
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Surname"
            if let surname = self.shortData?.contact.surname{
                textField.text = surname
            }else{
                textField.text = ""
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Number"
            if let number = self.shortData?.contact.number{
                textField.text = number
            }
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let name = alert?.textFields?[0].text,
               let number = alert?.textFields?[2].text?.onlyDigits(),
               name != "", number != "",
               let contact = self.shortData?.contact {
                
                var surname = alert?.textFields?[1].text
                if surname == "" { surname = nil }
                
                let newContact = Manager.change(contact: contact, with: name, surname: surname, number: number)
                
                if let tabBar = self.tabBarController as? ContactNode{
                    tabBar.title = newContact.getTitle()
                }
                self.number.setTitle(number, for: UIControl.State.normal)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in  }))

        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tabBar = tabBarController as? ContactNode{
            tabBar.view.tintColor = UIColor.blue
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let theContact = shortData?.contact else {
            return
        }
        number.setTitle(theContact.number, for: UIControl.State.normal)
        avatar.image = UIImage(named: theContact.photo ?? CallBookTableViewController.avatarDefault)
        email.setTitle(theContact.email ?? "Email", for: UIControl.State.normal)
    }
}
