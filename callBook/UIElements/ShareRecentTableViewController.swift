
import UIKit

class ShareRecentTableViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Manager.callLog.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCal", for: indexPath)

        let call = Manager.callLog[indexPath.row]
        let time = call.time
        cell.textLabel?.text = "\(time?.secondsToMinutes() ?? "Ever")   -   \(Manager.findContactBy(numberForSearching: call.abonent)?.getShortTitle() ?? call.abonent)"
        cell.detailTextLabel?.text = call.getDescription()
        return cell
    }
}
