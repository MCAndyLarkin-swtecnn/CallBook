
import UIKit

class RecentCalls: UITableViewController{
    lazy var index = (tabBarController as? ContactNode)?.index
    var shortData: ShortData?{
        var data: ShortData? = nil
        if let index = self.index{
            let contact: Contact = Manager.contactBook[index.section][index.row]
            data = (contact, Manager.findAllCallsBy(numberForSearching: contact.number))
        }
        return data
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shortData?.calls.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cal", for: indexPath)

        let calls = shortData?.calls

        if let time = calls?[indexPath.row].time{
            cell.textLabel?.text = time.secondsToMinutes()
        }else{
            cell.textLabel?.text = "Sometime"
        }
        
        cell.detailTextLabel?.text = calls?[indexPath.row].getDescription()
        
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBar = tabBarController as? ContactNode,
           let view = self.view as? UITableView{
            tabBar.view.tintColor = UIColor.green
            view.reloadData()
        }
        
    }
}

