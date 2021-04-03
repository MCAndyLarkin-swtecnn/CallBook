
import UIKit

class RecentCallsTableViewController: UITableViewController{
    let viewModel: LocalContactViewModel = ViewModelSingle.viewModel
    lazy var localRecents: RecentViewBook? = updateRecents(){
        didSet{
            if let tableView = self.view as? UITableView{
                tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        localRecents?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cal", for: indexPath)

        cell.textLabel?.text = localRecents?[indexPath.row].time ?? "Sometime"
        cell.detailTextLabel?.text = localRecents?[indexPath.row].description
        
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.view.tintColor = UIColor.green
    }
    func updateRecents() -> RecentViewBook?{
        guard let number = viewModel.getLocalContact()?.number else{
            return nil
        }
        return viewModel.getViewRecents(for: number)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.with(uploadRecent: { [weak self] in
            self?.localRecents = self?.updateRecents()
        })
    }
}

