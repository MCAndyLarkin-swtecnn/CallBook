//
//  FaceContact.swift
//  callBook
//
//  Created by user on 19.03.2021.
//

import UIKit

class FaceContact: UIViewController {
    lazy var tabBar = tabBarController as? ContactNode
    lazy var contact: Contact? = {
        if tabBar == nil{
            tabBar = tabBarController as? ContactNode
        }
        return tabBar?.shortData?.contact
    }()
    
    @IBOutlet var avatar: UIImageView!
    
    @IBOutlet var number: UIButton!
    @IBAction func changeContact(_ sender: UILongPressGestureRecognizer) {
        print("ChangeContact")
        
        let alert = UIAlertController(title: "Change the contact", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            if let name = self.contact?.name{
                textField.text = name
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Surname"
            if let surname = self.contact?.surname{
                textField.text = surname
            }else{
                textField.text = ""
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Number"
            if let number = self.contact?.number{
                textField.text = number
            }
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _  in  }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in  }))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let theContact = contact else {
            return
        }
        number.setTitle(theContact.number, for: UIControl.State.normal)
        
        avatar.image = UIImage(named: theContact.photo ?? CallBookTableViewController.avatarDefault)


    }
    
    override func viewWillAppear(_ animated: Bool) {
//        tabBar?.view.backgroundColor = view.backgroundColor
        tabBar?.view.tintColor = UIColor.blue
    }
    @IBAction func pressNumber(){
        guard let tabbar = tabBar,
              let contact = tabbar.shortData?.contact,
              let url = URL(string: "tel://\(contact.number.onlyDigits())")
        else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    

}
extension String {

    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
}
