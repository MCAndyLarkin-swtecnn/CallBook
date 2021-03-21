//
//  ContactNode.swift
//  callBook
//
//  Created by user on 19.03.2021.
//

import UIKit

class ContactNode: UITabBarController {
    public static let facePage = 0
    public static let recentPage = 1
    public static let messagePage = 2
    
    var shortData: (contact: Contact, calls: [Call])? = nil
    override func viewDidLoad() {
        view.backgroundColor = UIColor.orange
    }
    override func viewWillAppear(_ animated: Bool){
        if let data = shortData{
            let surname: String
            if let sur = data.contact.surname{
                surname = "\(sur) "
            }else{
                surname = ""
            }
            title = surname + data.contact.name
        }
    }
}
