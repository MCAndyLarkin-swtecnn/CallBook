
import UIKit

class ShareRecentTableViewController: UITableViewController {
    lazy var recentBook: RecentViewBook? = ViewModelSingle.viewModel.getViewRecents()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentBook?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCal", for: indexPath)

        let call = recentBook?[indexPath.row]
        cell.textLabel?.text = call?.getTitle()
        cell.detailTextLabel?.text = call?.description
        return cell
    }
}
