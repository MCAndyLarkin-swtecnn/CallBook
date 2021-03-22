//
//  ShareRecentTableViewController.swift
//  callBook
//
//  Created by user on 22.03.2021.
//

import UIKit

class ShareRecentTableViewController: UITableViewController {
    var callList: [Call]? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callList?.count ?? 0
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCal", for: indexPath)

        if let calls = callList{
            let time = calls[indexPath.row].time
            cell.textLabel?.text = time.secondsToMinutes()
                    
            var io: String
            switch calls[indexPath.row].io{
            case .inputFail:
                io = "Missed"
            case .inputSuccess(let length):
                io = "Incoming - \(length.secondsToMinutes())"
            case .outputFail:
                io = "Don't got through"
            case .outputSucces(let length):
                io = "Outgoing - \(length.secondsToMinutes())"
            }
            cell.detailTextLabel?.text = io
        
    }
        return cell
    
}
}
