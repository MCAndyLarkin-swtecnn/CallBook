
import UIKit
import ContactsUI


extension CallBookTableViewController: CNContactViewControllerDelegate {
    @IBAction func addView(_ sender: Any) {
        let controller = CNContactViewController(forNewContact: nil)
        controller.contactStore = CNContactStore()
        controller.delegate = self
        let navigationController = UINavigationController(rootViewController: controller)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?){
        //MARK: How to send data to model?
//        guard let contact = contact, let newContact = Contact(from: contact) else {
//            viewController.dismiss(animated: true, completion: nil)
//            return
//        }
//        Manager.addNew(contactToBook: newContact)
//        if let tableView = self.view as? UITableView{
//            tableView.reloadData()
//        }
//        viewModel.

    }
}
//extension CNContact
extension Contact{
    init?(from contact: CNContact){
        let name = contact.givenName
        guard !name.isEmpty else{
            return nil
        }

        var optnumber: String? = nil
        for number in contact.phoneNumbers{
            let cleanNumber = number.value.stringValue.onlyDigits()
            if !cleanNumber.isEmpty{
                optnumber = cleanNumber
                break
            }
        }
        guard let number = optnumber else {
            return nil
        }

        var surname: String?
        if contact.familyName.isEmpty {
            surname = nil
        }else{
            surname = contact.familyName
        }

        var email: String? = nil
        for email_ in contact.emailAddresses{
            let cleanEmail = email_.value as String
            if !cleanEmail.isEmpty{
                email = cleanEmail
                break
            }
        }
        
        self.init(name: name, surname: surname, number: number, email: email, birthday: contact.birthday)
    }
}
