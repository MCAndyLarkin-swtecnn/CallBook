//
//  FaceContact.swift
//  callBook
//
//  Created by user on 19.03.2021.
//

import UIKit

class FaceContact: UIViewController {

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var number: UIButton!
    
    @IBAction func pressNumber(){
        guard let tabBar = self.tabBarController as? ContactNode,
              let contact = tabBar.shortData?.contact,
              let url = URL(string: "tel://\(contact.number.onlyDigits())")
        else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    @IBAction func changeContact(_ sender: UILongPressGestureRecognizer) {
        print("ChangeContact")
        
        let alert = UIAlertController(title: "Change the contact", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            if  let tabBar = self.tabBarController as? ContactNode, let name = tabBar.shortData?.contact.name{
                textField.text = name
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Surname"
            if  let tabBar = self.tabBarController as? ContactNode, let surname = tabBar.shortData?.contact.surname{
                textField.text = surname
            }else{
                textField.text = ""
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Number"
            if  let tabBar = self.tabBarController as? ContactNode, let number = tabBar.shortData?.contact.number{
                textField.text = number
            }
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let name = alert?.textFields?[0].text, let number = alert?.textFields?[2].text?.onlyDigits(){
                var surname = alert?.textFields?[1].text
                if surname == ""{
                    surname = nil}
                if let tabBar = self.tabBarController as? ContactNode, let contact = tabBar.shortData?.contact{
                    tabBar.changeData?(contact, name, surname, number)
                    tabBar.updateData?()
                }
                if  let tabBar = self.tabBarController as? ContactNode{
                    self.number.setTitle(number, for: UIControl.State.normal)
                    tabBar.updateTitle()
                }

            }
            if let tableView = self.view as? UITableView{
                tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in  }))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard  let tabBar = self.tabBarController as? ContactNode, let theContact = tabBar.shortData?.contact else {
            return
        }
        number.setTitle(theContact.number, for: UIControl.State.normal)
        
        avatar.image = UIImage(named: theContact.photo ?? CallBookTableViewController.avatarDefault)


    }
    
    override func viewWillAppear(_ animated: Bool) {
        if  let tabBar = self.tabBarController as? ContactNode{
            tabBar.view.tintColor = UIColor.blue
        }
    }


}
extension String {
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
}
