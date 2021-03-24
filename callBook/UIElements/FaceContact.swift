
import UIKit

class FaceContact: TabBarPageViewController{
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var number: UIButton!
    
    var inserter: ((Call) -> ())? = nil
    
    @IBAction func pressNumber(){
        guard let number = shortData?.contact.number
        else { return }
        
        if let url = URL(string: "tel://\(number.onlyDigits())"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        //Write to callLog
        //Default (No responce, time - random)
        inserter?(Call(abonent: number,
                       io: .outputFail,
                       time: Int.random(in: 100..<500)))
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
            if let name = alert?.textFields?[0].text, let number = alert?.textFields?[2].text?.onlyDigits(),
               name != "", number != ""{
                var surname = alert?.textFields?[1].text
                if surname == "" { surname = nil }
                if let contact = self.shortData?.contact{
                    contact.name = name
                    contact.surname = surname
                    contact.number = number
                    if let tabBar = self.tabBarController as? ContactNode{
                        tabBar.title = contact.getTitle()
                    }
                }
                self.number.setTitle(number, for: UIControl.State.normal)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in  }))

        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let theContact = shortData?.contact else {
            return
        }
        number.setTitle(theContact.number, for: UIControl.State.normal)
        avatar.image = UIImage(named: theContact.photo ?? CallBookTableViewController.avatarDefault)

        if let tabBar = tabBarController as? ContactNode{
            tabBar.view.tintColor = UIColor.blue
        }
    }
}
