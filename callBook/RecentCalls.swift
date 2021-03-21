//
//  RecentCalls.swift
//  callBook
//
//  Created by user on 19.03.2021.
//

import UIKit

class RecentCalls: UITableViewController {
    
    
    lazy var tabBar = tabBarController as? ContactNode

    
    override func viewWillAppear(_ animated: Bool) {
        tabBar?.view.tintColor = UIColor.green
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabBar?.shortData?.calls.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cal", for: indexPath)

        let calls = tabBar?.shortData?.calls

        if let time = calls?[indexPath.row].time{
            cell.textLabel?.text = time.secondsToMinutes()
        }else{
            cell.textLabel?.text = "Sometimes"
        }
        
        var io: String
        switch  calls?[indexPath.row].io{
            case .inputFail:
                io = "Missed"
        case .inputSuccess(let length):
            io = "Incoming - \(length.secondsToMinutes())"
            case .outputFail:
                io = "Don't got through"
        case .outputSucces(let length):
            io = "Outgoing - \(length.secondsToMinutes())"
        case .none:
                io = "HZ, chto eto"
        }
        cell.detailTextLabel?.text = io
        
        return cell
    }
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        rowHeigth
//    }

}

extension Int {
    func secondsToMinutes() -> String{
        return "\(Int(self/60)):\(self % 60)"
    }
}
