
import UIKit

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

class CallBookTableViewController: UITableViewController {
    public static let avatarDefault = "avatar"
    let rowHeigth: CGFloat = 70.0
    let headerHight: CGFloat = 40.0
    
    @IBAction func addView(_ sender: Any) {
        let alert = UIAlertController(title: "Add new contact", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Surname"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Number"
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let name = alert?.textFields?[0].text, let number = alert?.textFields?[2].text?.onlyDigits(),
               name != "", number != ""{
                var surname = alert?.textFields?[1].text
                if surname == "" { surname = nil }
                Manager.addNew(contactToBook: Contact(name: name, surname: surname, number: number,email: nil))
            }
            if let tableView = self.view as? UITableView{
                tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {_ in }))

        self.present(alert, animated: true, completion: nil)
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
        Manager.withUpload{ [weak view = view as? UITableView] in view?.reloadData() }
        let alert = UIAlertController(title: "Choose raspil method", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GCD", style: .default, handler: {_ in
            Manager.loadData(by: .gcd)
        }))
        alert.addAction(UIAlertAction(title: "Operations", style: .default, handler: {_ in
            Manager.loadData(by: .operations)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

