
import UIKit

class RecentCalls: UITableViewController{

    var viewModel: LocalContactViewModel = ViewModelSingle.viewModel
    var localRecents: RecentViewBook?{
        if let index = index?.onlyCoords(), let number = viewModel.getLocalContact(by: index)?.number {
            return viewModel.getViewRecents(for: number)
        }
        return nil
    }
    lazy var index = (tabBarController as? ContactNode)?.index
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localRecents?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cal", for: indexPath)


        cell.textLabel?.text = localRecents?[indexPath.row].time ?? "Sometime"
        
        cell.detailTextLabel?.text = localRecents?[indexPath.row].description
        
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

