
import UIKit
import ContactsUI

//Questions
/*
 1. Tab bar Color
 2. Глюк с отображением сообщений (prepare(), seque, willApear, DidLoad) //May use singleton access to dataManager (interfaceFactory)
 6. переход не на первую страницу в тачбаре
 3. Scrollable
 4. Выравнивание stack view по низу
 5. перенос строки в textField
 7. Сворачивать секции в TableView
 */

class CallBookTableViewController: UITableViewController{
    public static let avatarDefault = "avatar"
    let rowHeigth: CGFloat = 70.0
    let headerHight: CGFloat = 40.0
    
    @IBOutlet var WaitIndicator: UIActivityIndicatorView!
    @IBAction func addView(_ sender: Any) {
        let controller = CNContactViewController(forNewContact: nil) //(forNewContact: contact)
        controller.contactStore = CNContactStore()
        controller.delegate = self
        let navigationController = UINavigationController(rootViewController: controller)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let action = UIContextualAction(style: .normal, title: "Delete"){
                [weak self] (action, view, completionHandler) in
                
                self?.deleteView(index: indexPath)
                
                completionHandler(true)
            }
        action.backgroundColor = .purple
            let configuration = UISwipeActionsConfiguration(actions: [action])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Call"){ (action, view, completionHandler) in
            
            let number = Manager.contactBook[indexPath.section][indexPath.row].number.onlyDigits()
            
            if let url = URL(string: "tel://\(number)"){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            Manager.addNew(callToLog: Call(abonent: number, io: .outputFail))
            
            completionHandler(true)
        }
        action.backgroundColor = .cyan
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Manager.contactBook.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Manager.contactBook[section].count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeigth
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        
        let contact = Manager.contactBook[indexPath.section][indexPath.row]
        
        cell.signature?.text = contact.getTitle()
        cell.number?.text = contact.number
        cell.photo?.image = UIImage(named: contact.photo ?? CallBookTableViewController.avatarDefault)
        cell.messageButton?.index = indexPath
        
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.03)
        
        let img = UIImageView(image: UIImage(systemName: "doc.plaintext"))
        img.frame = CGRect(x:5,y:8,width: 25,height: 25)
        img.tintColor = UIColor.systemPink.withAlphaComponent(0.2)
        headerView.addSubview(img)
        
        let label = UILabel()
        
        label.frame = CGRect(x: 35, y: 8, width: 100, height: 25)
        label.textColor = UIColor.systemPink.withAlphaComponent(0.5)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        
        if Manager.contactBook.count >= section+1{
            let contact = Manager.contactBook[section][0]
            label.text = contact.getSectionName()
        }
        
        headerView.addSubview(label)
        return headerView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ContactNode{
            if segue.identifier == "openFace",
               let indexPath = tableView.indexPathForSelectedRow{
                destination.index = indexPath
            } else
            if segue.identifier == "openMessage",
               let but = sender as? MessageButton,
               let index = but.index{
                destination.index = index
                destination.selectedPage = .message
            }
        }
    }
    
    func deleteView(index: IndexPath){
        Manager.delete(index: (index.section, index.row))
        if let tableView = self.view as? UITableView{
            tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tableView = self.view as? UITableView{
            tableView.reloadData()
        }
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        Manager.withUpload{ [weak view = view as? UITableView] in
            view?.reloadData()
            self.stopWaitIndicator()
        }
        let alert = UIAlertController(title: "Choose raspil method", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GCD", style: .default, handler: {_ in
            Manager.loadData(by: .gcd)
            self.showWaitIndicator()
        }))
        alert.addAction(UIAlertAction(title: "Operations", style: .default, handler: {_ in
            Manager.loadData(by: .operations)
            self.showWaitIndicator()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    private func showWaitIndicator(){
        WaitIndicator.isHidden = false
        WaitIndicator.startAnimating()
    }
    private func stopWaitIndicator(){
        WaitIndicator.stopAnimating()
    }
}

extension CallBookTableViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?){
        guard let contact = contact, let newContact = Contact(from: contact) else {
            viewController.dismiss(animated: true, completion: nil)
            return
        }
        Manager.addNew(contactToBook: newContact)
        if let tableView = self.view as? UITableView{
            tableView.reloadData()
        }
    }
}
extension Contact{
    convenience init?(from contact: CNContact){
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
        
        self.init(name: name, surname: surname, number: number, email: email)
    }
}
