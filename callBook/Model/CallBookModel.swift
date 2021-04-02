
import Foundation

/*Quections
 1. Хранить жесткую ссылку на себя это утечка?
 */

//protocol CallBookModelProtocol{
//    var notifyViewModel: () -> () {get set}
//    init(notify: @escaping () -> ())
//}
//protocol ContactsModelProtocol: CallBookModelProtocol {
//    var contactBook: ContactBook {get set}
//    func with(contactBook: ContactBook)
//}
//protocol RecentsModelProtocol: CallBookModelProtocol {
//    var recentBook: RecentBook { get set }
//    func with(recentBook: RecentBook)
//}
class CallBookModel/*: ContactsModelProtocol, RecentsModelProtocol*/ {
    //MARK: TODO: Should use sorted array type for 'contact book'
    var contactBook: ContactBook = []{
        didSet{
            print()
            OperationQueue.main.addOperation{ [weak self] in
                self?.notifyContactsViewModel()
            }
        }
    }
    var recentBook: RecentBook = [] {
        didSet{
            notifyRecentsViewModel()
        }
    }
    
    func with(contactBook: ContactBook) {
        self.contactBook = contactBook
    }
    func with(recentBook: RecentBook) {
        self.recentBook = recentBook
    }
    
    var notifyContactsViewModel: () -> ()
    var notifyRecentsViewModel: () -> ()
    
    required init(notifyContactsViewModel: @escaping () -> (), notifyRecentsViewModel: @escaping () -> ()) {
        self.notifyContactsViewModel = notifyContactsViewModel
        self.notifyRecentsViewModel = notifyRecentsViewModel
    }
}
