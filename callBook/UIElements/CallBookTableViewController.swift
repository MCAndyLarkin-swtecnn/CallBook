
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


//Use reload  section
class CallBookTableViewController: UITableViewController {
    public static let avatarDefault = "avatar"
    let rowHeigth: CGFloat = 70.0
    let headerHight: CGFloat = 40.0
    
    lazy var dataManager: Manager = Manager().andLoadData().withUpload{
        if let tableView = self.view as? UITableView{
            print("Upload")
            tableView.reloadData()
        }
    }
    
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
                self.dataManager.addNew(contactToBook: Contact(name: name, surname: surname, number: number,email: nil))
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
        let action = UIContextualAction(style: .normal, title: "Call"){
            [weak self] (action, view, completionHandler) in
            
            guard let number = self?.dataManager.contactBook[indexPath.section][indexPath.row].number
            else { return }
            
            if let url = URL(string: "tel://\(number.onlyDigits())"){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            //Write to callLog
            //Default (No responce, time - random)
            self?.dataManager.addNew(callToLog: Call(abonent: number,
                                          io: .outputFail,
                                          time: Int.random(in: 100..<500)))
            
            completionHandler(true)
        }
        action.backgroundColor = .cyan
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataManager.contactBook.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.contactBook[section].count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeigth
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        
        let contact = dataManager.contactBook[indexPath.section][indexPath.row]
        
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
        
        
        guard dataManager.contactBook.count >= section+1, let contact = try? dataManager.contactBook[section][0] else{
            return nil
        }
        label.text = contact.getSectionName()
        
        label.frame = CGRect(x: 35, y: 8, width: 100, height: 25)
        label.textColor = UIColor.systemPink.withAlphaComponent(0.5)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ContactNode{
            var page: ContactNode.Page
            var index: IndexPath
            if let indexPath = tableView.indexPathForSelectedRow{
                index = indexPath
                page = .face
            } else if segue.identifier == "openMessage", let but = sender as? MessageButton, let index_ = but.index{
                index = index_
                page = .message
            }else{
                return
            }
            
            let contact: Contact = dataManager.contactBook[index.section][index.row]
            let shortData = (contact, dataManager.findAllCallsBy(numberForSearching: contact.number))
            if let pages = destination.viewControllers{
                for _page in pages{
                    if let page = _page as? TabBarPageViewController{
                        page.shortData = shortData
                    }else
                    if let page = _page as? RecentCalls{
                        page.shortData = shortData
                    }
                }
                
                if let faceContact = pages[ContactNode.Page.face.rawValue] as? FaceContact,
                   let recentContact = pages[ContactNode.Page.recent.rawValue] as? RecentCalls,
                   let recentView = recentContact.view as? UITableView{
                    faceContact.inserter = { [weak manager = dataManager] (call) in
                        manager?.addNew(callToLog: call)
                        recentContact.shortData?.calls.insert(call, at: 0)
                        recentView.reloadData()
                    }
                }
            }
            
            destination.selectedPage = .recent
        }else if let destination = segue.destination as? ShareRecentTableViewController, segue.identifier == "ShareRecent" {
            destination.callList = dataManager.callLog
            destination.nameFinder = { [weak manager = dataManager] (number) in
                manager?.findContactBy(numberForSearching: number)?.getShortTitle()
            }
        }
    }
    
    func deleteView(index: IndexPath){
        dataManager.delete(index: (index.section, index.row))
        if let tableView = self.view as? UITableView{
            tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if let tableView = self.view as? UITableView{
            tableView.reloadData()
        }
    }
}
