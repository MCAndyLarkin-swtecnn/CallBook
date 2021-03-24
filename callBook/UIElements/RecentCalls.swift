
import UIKit

class RecentCalls: UITableViewController {
    var shortData: (contact: Contact, calls: [Call])? = nil
    
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
        if let tabBar = tabBarController as? ContactNode{
            tabBar.view.tintColor = UIColor.green
        }
    }

}

