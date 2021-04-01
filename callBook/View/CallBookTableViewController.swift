
import UIKit
import ContactsUI

class CallBookTableViewController: UITableViewController, CallBookView{
    var contactBook: ContactViewsBook?
    
    @IBOutlet var WaitIndicator: UIActivityIndicatorView!
    
    var viewModel: CallBookViewModelProtocol?
    
    let rowHeigth: CGFloat = 70.0
    let headerHight: CGFloat = 40.0
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Delete"){
            [weak self] (action, view, completionHandler) in
            
            self?.viewModel?.lets(.delete, for: indexPath.onlyCoords())
            
            completionHandler(true)
        }
        action.backgroundColor = .purple
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Call"){ [weak self] (action, view, completionHandler) in
            
            self?.viewModel?.lets(.makeCall, for: indexPath.onlyCoords())
            
            completionHandler(true)
        }
        action.backgroundColor = .cyan
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        contactBook?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactBook?[section].count ?? 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeigth
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        
        if let contact = contactBook?[indexPath.section][indexPath.row]{
            
            cell.signature?.text = contact.signature
            cell.number?.text = contact.number
            cell.photo?.image = UIImage(named: contact.photo)
            cell.messageButton?.index = indexPath
        }
        
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
        
        label.frame = CGRect(x: 35, y: 8, width: 100, height: 25)
        label.textColor = UIColor.systemPink.withAlphaComponent(0.5)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        
//        if viewModel.getDimension() >= section+1{
        if let sectionName = contactBook?[section][0].getSectionName(){
            label.text = sectionName
        }
//        }
        
        headerView.addSubview(label)
        return headerView
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ContactNode{
            if segue.identifier == "openFace",
               let indexPath = tableView.indexPathForSelectedRow{
                destination.index = indexPath
            } else
            if segue.identifier == "openMessage",
               let but = sender as? MessageButton,
               let index = but.index{
                destination.index = index
                destination.selectedPage = .message
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tableView = self.view as? UITableView{
            tableView.reloadData()
        }
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        viewModel = CallBookViewModel(view: self){ [weak self] in
            if let tableView = self?.view as? UITableView{
                tableView.reloadData()
                self?.stopWaitIndicator()
            }
        }
        let alert = UIAlertController(title: "Choose raspil method", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GCD", style: .default, handler: {_ in
            self.showWaitIndicator()
            self.viewModel?.loadData(method: .gcd)
        }))
        alert.addAction(UIAlertAction(title: "Operations", style: .default, handler: {_ in
            self.showWaitIndicator()
            self.viewModel?.loadData(method: .operations)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    private func showWaitIndicator(){
        WaitIndicator.isHidden = false
        WaitIndicator.startAnimating()
    }
    private func stopWaitIndicator(){
        WaitIndicator.stopAnimating()
    }
}
