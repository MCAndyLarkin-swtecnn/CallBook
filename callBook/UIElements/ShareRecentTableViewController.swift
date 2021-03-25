
import UIKit

class ShareRecentTableViewController: UITableViewController {
    var callList: [Call]?
    var nameFinder: ((String) -> String?)?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCal", for: indexPath)

        if let calls = callList{
            let call = calls[indexPath.row]
            let time = call.time
            cell.textLabel?.text = "\(time.secondsToMinutes())   -   \(nameFinder?(call.abonent) ?? call.abonent)"
            cell.detailTextLabel?.text = call.getDescription()
        }
        return cell
    }
}
