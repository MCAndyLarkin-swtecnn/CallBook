
import Foundation

import UIKit

protocol CallBookViewModelProtocol{
    var manager: Manager {get set}
    var view: CallBookView? {get set}
    var uploadContactBook: (()->())? { get set}
    
    init(view: CallBookView, uploadContactBook: @escaping ()->())
    func lets(_ activity: Activity,  for cell: Dimension)
    
    func notifyToChangesInModel()
//    func notifyToChangesInView()
    
    func loadData(method: Raspil)
}

final class CallBookViewModel: CallBookViewModelProtocol{
    
    weak var view: CallBookView?
    
    lazy var manager = Manager(viewModel: self)
    var uploadContactBook: (() -> ())?
    
    init(view: CallBookView, uploadContactBook: @escaping ()->()){
        self.uploadContactBook = uploadContactBook
        self.view = view
        self.insertViewContacts()
    }
    
    func insertViewContacts(){
        view?.contactBook =  manager.contactBook.map{ section in
            section.map{ contact in
                contact.getCallBookContactView()
            }
        }
    }
    func notifyToChangesInModel() {
        insertViewContacts()
        uploadContactBook?()
    }
    
    func lets(_ activity: Activity, for cell: Dimension) {
        switch activity {
        case .delete:
            manager.delete(index: (cell.sections, cell.rows))
            uploadContactBook?()

        case .makeCall:
            let number = manager.contactBook[cell.sections][cell.rows].number.onlyDigits()
            if let url = URL(string: "tel://\(number)"){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            manager.addNew(callToLog: Call(abonent: number, io: .outputFail))
        }
    }
    func loadData(method: Raspil){
        manager.loadData(by: method)
    }
}

enum Activity {
    case delete
    case makeCall
}
