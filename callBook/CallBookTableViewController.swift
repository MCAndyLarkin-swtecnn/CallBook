//
//  CallBookTableViewController.swift
//  callBook
//
//  Created by user on 19.03.2021.
//

import UIKit

//Questions
/*
 1. Tab bar Color
 2. Глюк с отображением сообщений
 3. Scrollable
 4. Выравнивание stack view по низу
 5. перенос строки в textField
 6. переход не на первыю страницу в тачбаре
 */

class CallBookTableViewController: UITableViewController {
    
    
    public static let avatarDefault = "avatar"
    let rowHeigth: CGFloat = 70.0
    let headerHight: CGFloat = 40.0
    
    lazy var dataManager: Manager = {
        let manager = Manager()
        manager.loadData()
        manager.checkDataToLog()
        return manager
    }()
    
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
            if let name = alert?.textFields?[0].text, let number = alert?.textFields?[2].text?.onlyDigits(){
                var surname = alert?.textFields?[1].text
                if surname == "" {
                    surname = nil}
                self.dataManager.addNew(contactToBook: Contact(name: name, surname: surname, number: number, photo: nil, message: nil))
            }
            self.dataManager.checkDataToLog()
            if let tableView = self.view as? UITableView{
                tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {_ in }))

        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let action = UIContextualAction(style: .normal, title: "delete"){
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
            
            guard let number = self?.dataManager.contactBook[indexPath.section][indexPath.row].number,
                  let url = URL(string: "tel://\(number.onlyDigits())")
            else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        
            let contact = dataManager.contactBook[indexPath.section][indexPath.row]
            
            let surname: String
            if let sur = contact.surname{
                surname = "\(sur) "
            }else{
                surname = ""
            }
    //        print(standardizeNumber(number: contact.number))
            //Try use guard let
            //Try use if let cond, cond
            
            cell.signature?.text = surname + contact.name
            cell.number?.text = contact.number
            cell.photo?.image = UIImage(named: contact.photo ?? CallBookTableViewController.avatarDefault)
        
        

        cell.messageButton?.index = (indexPath.section, indexPath.row)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeigth
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.03)
        
        let img = UIImageView(image: UIImage(systemName: "doc.plaintext"))
        img.frame = CGRect(x:5,y:8,width: 25,height: 25)
        img.tintColor = UIColor.systemPink.withAlphaComponent(0.2)
        headerView.addSubview(img)
        
        let label = UILabel()
        

            let contact = dataManager.contactBook[section][0]

            if let sur = contact.surname{
                label.text = String(sur.prefix(1)).uppercased()
            }else{
                label.text = String(contact.name.prefix(1)).uppercased()
            }
        
        
        
        label.frame = CGRect(x: 35, y: 8, width: 100, height: 25)
        label.textColor = UIColor.systemPink.withAlphaComponent(0.5)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        headerView.addSubview(label)
        
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHight
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ContactNode{
            
            destination.changeData = { [weak manager = dataManager]
                (contact: Contact, name: String?, surname: String?, number: String?) in
                manager?.change(contact: contact, name: name, surname: surname, number: number)
                if let tableView = self.view as? UITableView{
                    tableView.reloadData()
                }
            }
            if let indexPath = tableView.indexPathForSelectedRow {
                let contact = dataManager.contactBook[indexPath.section][indexPath.row]
                destination.updateData = { [weak manager = dataManager] in
                    if let manager = manager{
                    destination.shortData = (contact, manager.findAllCallsByNumber(numberForSearching: contact.number))
                    }
                }
                destination.updateData?()
            }else if segue.identifier == "openMessage", let but = sender as? MessageButton, let index = but.index{
                destination.selectedIndex = ContactNode.messagePage
                let contact = dataManager.contactBook[index.section][index.row]
                destination.updateData = { [weak manager = dataManager] in
                    if let manager = manager{
                    destination.shortData = (contact, manager.findAllCallsByNumber(numberForSearching: contact.number))
                    }
                }
                destination.updateData?()
                destination.view.tintColor = UIColor.orange
            }
        }else if segue.identifier == "ShareRecent", let destination = segue.destination as? ShareRecentTableViewController{
            destination.callList = dataManager.callLog
                
        }
    }
    
    func deleteView(index: IndexPath){
        dataManager.delete(index: index)
        if let tableView = self.view as? UITableView{
            tableView.reloadData()
        }
    }

}
