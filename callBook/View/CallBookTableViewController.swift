
import UIKit

class CallBookTableViewController: UITableViewController{
    @IBOutlet var WaitIndicator: UIActivityIndicatorView!
    
    var viewModel: ContactsViewModelProtocol = ViewModelSingle.viewModel
    lazy var contactBook: ContactViewsBook? = viewModel.getViewContacts()
    
    let rowHeigth: CGFloat = 70.0
    let headerHight: CGFloat = 40.0
    
    let startOnSettingTag = "start_on"
    let StartOnContactsSettingTitle = "StartOnContactsSettingTitle"
    let StartOnRecentsSettingTitle = "StartOnRecentsSettingTitle"
    let StartOnAddingSettingTitle = "StartOnAddingSettingTitle"
    var protectFlag = false
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Delete"){
            [weak self] (action, view, completionHandler) in
            
            self?.viewModel.deleteContact(by: indexPath.onlyCoords())
            completionHandler(true)
        }
        action.backgroundColor = .purple
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    

    @IBAction func tapToTitle(_ sender: TitleCircleView) {
        //Animating will be here
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Call"){ [weak self] (action, view, completionHandler) in
            self?.viewModel.makeCall(forNumberby: indexPath.onlyCoords())
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
        
        if let contact = contactBook?[indexPath.section][indexPath.row]{
            cell.signature?.text = contact.signature
            cell.number?.text = contact.number
            if contact.photo == "avatar"{
                cell.titleView.isHidden = false
                cell.titleView?.text = contact.signature
                cell.titleView?.backgroundColor = UIColor.clear
                cell.photo.isHidden = true
            }else{
                cell.photo.isHidden = false
                cell.photo.loadGif(url: contact.photo)
                cell.titleView.isHidden = true
            }
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
        
        if let sectionName = contactBook?[section][0].getSectionName(){
            label.text = sectionName
        }
        
        headerView.addSubview(label)
        return headerView
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ContactNodeTabBarController{
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func processStartSettings(){
        guard !protectFlag, let startSetting = UserDefaults.standard.string(forKey: startOnSettingTag)
        else { return }
        protectFlag = !protectFlag
        switch startSetting {
        case StartOnRecentsSettingTitle:
            performSegue(withIdentifier: "ShareRecent", sender: self)
        case StartOnAddingSettingTitle:
            showAddingContactView()
        default:
            break
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
        viewModel.with{ [weak self] in
            if let tableView = self?.view as? UITableView{
                self?.contactBook = self?.viewModel.getViewContacts()
                tableView.reloadData()
            }
            self?.stopWaitIndicator()
            self?.processStartSettings()
        }.with(selebrating: { birthday in
            let content = UNMutableNotificationContent()
            content.body = "Today is Birthday of \(birthday.name) \(birthday.surname ?? "")!"
            content.title = "Don't forget to congratulate!"
            content.sound = .default
            var date = Calendar.current.dateComponents([.minute, .day, .month,.hour,.second], from: Date())
            if date.minute != nil{
                date.second! += 20
            }
            UNUserNotificationCenter.current().add(
                UNNotificationRequest(identifier: birthday.getTitle(), content: content,
                                      trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false))
            ){  error in
                if let err = error{ print("ErrorNotiaication - \(err)") }
            }
        })
        askAboutDataSource()
    }
    func askAboutRaspilMethod(){
        let alert = UIAlertController(title: "Choose raspil method", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GCD", style: .default, handler: {_ in
            self.viewModel.loadData(source: .network(method: .gcd))
        }))
        alert.addAction(UIAlertAction(title: "Operations", style: .default, handler: {_ in
            self.viewModel.loadData(source: .network(method: .operations))
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func askAboutDataSource(){
        let alert = UIAlertController(title: "Where from get data?", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Network", style: .default, handler: {_ in
            self.showWaitIndicator()
            self.askAboutRaspilMethod()
        }))
        alert.addAction(UIAlertAction(title: "FileSystem", style: .default, handler: {_ in
            self.showWaitIndicator()
            self.viewModel.loadData(source: .fileSystem)
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
