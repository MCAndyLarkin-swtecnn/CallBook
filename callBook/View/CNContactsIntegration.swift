
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
        guard let contact = contact else {
            viewController.dismiss(animated: true, completion: nil)
            return
        }
        viewModel.addNewContactBy(contact.getDataSet())
        if let tableView = self.view as? UITableView{
            tableView.reloadData()
        }
    }
}
typealias ContactDataSet = (name: String, surname: String?, number: String, email: String?, birthday: DateComponents?, photo: String?)

extension CNContact{
    func getDataSet() -> ContactDataSet?{
        let name = self.givenName
        guard !name.isEmpty else{
            return nil
        }

        var optnumber: String? = nil
        for number in self.phoneNumbers{
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
        if self.familyName.isEmpty {
            surname = nil
        }else{
            surname = self.familyName
        }

        var email: String? = nil
        for email_ in self.emailAddresses{
            let cleanEmail = email_.value as String
            if !cleanEmail.isEmpty{
                email = cleanEmail
                break
            }
        }
        return (name: name, surname: surname, number: number, email: email, birthday: birthday, photo: nil)
    }
}
