
import UIKit

class FaceContactViewController: UIViewController{
    
    var viewModel: LocalContactViewModel = ViewModelSingle.viewModel
    lazy var localContact = viewModel.getLocalContact(){
        didSet{
            setViews()
        }
    }

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var number: UIButton!
    @IBOutlet var email: UIButton!
    @IBOutlet var birthday: UIButton!

    @IBAction func pressNumber(){
        guard let number = localContact?.number.onlyDigits()
        else { return }
        viewModel.makeCall(by: number)
    }

    @IBAction func changeContact(_ sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Change the contact", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            if let name = self.localContact?.name{
                textField.text = name
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Surname"
            if let surname = self.localContact?.surname{
                textField.text = surname
            }else{
                textField.text = ""
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Number"
            if let number = self.localContact?.number{
                textField.text = number
            }
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let name = alert?.textFields?[0].text,
               let number = alert?.textFields?[2].text?.onlyDigits(),
               name != "", number != ""{

                var surname = alert?.textFields?[1].text
                if surname == "" { surname = nil }

                let newContact = self.viewModel.changeContact(name: name, surname: surname, number: number)
//
                if let tabBar = self.tabBarController as? ContactNodeTabBarController,
                   let contact = newContact{
                    tabBar.title = FullName(dataSet: contact).getTitle()
                }
//                self.number.setTitle(number, for: UIControl.State.normal)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in  }))

        self.present(alert, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.view.tintColor = UIColor.blue
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        viewModel.with(uploadFace:{ [weak self] in
            self?.localContact = self?.viewModel.getLocalContact()
        })
    }
    func setViews(){
        guard let theContact = localContact else {
            return
        }
        number.setTitle(theContact.number, for: UIControl.State.normal)
        avatar.image = UIImage(named: theContact.photo)
        email.setTitle(theContact.email ?? "Email", for: UIControl.State.normal)

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        if let date = theContact.birthday?.date{
            birthday.setTitle(formatter.string(from: date), for: UIControl.State.normal)
        }
    }
}
