
import UIKit

class ShareRecentTableViewController: UITableViewController, RecentBookViewProtocol {
    var viewModel: RecentsViewModelProtocol = ViewModelSingle.viewModel
    lazy var recentBook: RecentViewBook? = viewModel.getViewRecents()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentBook?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCal", for: indexPath)

        let call = recentBook?[indexPath.row]
        cell.textLabel?.text = call?.title
        cell.detailTextLabel?.text = call?.description
        return cell
    }
    override func viewDidLoad() {
        viewModel.with{ [weak self] in
            if let tableView = self?.view as? UITableView{
                self?.recentBook = self?.viewModel.getViewRecents()
                tableView.reloadData()
            }
        }
    }
}
