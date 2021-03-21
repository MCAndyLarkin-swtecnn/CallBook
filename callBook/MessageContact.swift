//
//  MessageContact.swift
//  callBook
//
//  Created by user on 20.03.2021.
//

import UIKit

class MessageContact: UIViewController {
    
    @IBOutlet var messageField: UITextField!
    
    @IBOutlet var templateMessage1: UILabel!
    @IBOutlet var templateMessage2: UILabel!
    @IBOutlet var templateMessage3: UILabel!
    
    lazy var tabBar = tabBarController as? ContactNode
    lazy var contact: Contact? = {
        if tabBar == nil{
            tabBar = tabBarController as? ContactNode
        }
        return tabBar?.shortData?.contact
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("didLoad")
        loadMessages()
    }
    override func viewWillAppear(_ animated: Bool) {
//        tabBar?.view.backgroundColor = UIColor.red
        print("willAppear")
        tabBar?.view.tintColor = UIColor.orange
        loadMessages()
    }
    public func loadMessages(){
        guard let theContact = contact else {
            print("guard")
            return
        }
        if let message = theContact.message, let history = message.history{
            templateMessage1.text = history[0].text
            templateMessage2.text = history[1].text
            templateMessage3.text = history[2].text
            messageField.text = message.draft
        }else{
            print("no message")
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
