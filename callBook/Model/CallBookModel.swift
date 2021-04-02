
import Foundation

/*Quections
 1. Хранить жесткую ссылку на себя это утечка?
 */

protocol CallBookModelProtocol{
//    var contactBook: ContactBook {get set}
//    var recentBook: RecentBook {get set}
//    var localContact: Contact? {get set}
    func getContactBook() -> ContactBook
    func getRecentBook() -> RecentBook
    func getLocalContact() -> Contact?
    
    func initLocal(by index: Dimension)
    func with(contactBook: ContactBook)
    func with(recentBook: RecentBook)
    
    func with(notifyContactsViewModel: @escaping () -> ()) -> Self
    func with(notifyRecentsViewModel: @escaping () -> ()) -> Self
    func with(notifyContactNodeViewModel: @escaping () -> ()) -> Self
    
    func deleteContact(in index: Dimension)
    func getContact(by index: Dimension) -> Contact?
    func getContact(by number: String) -> Contact?
    func getRecents(by number: String) -> RecentBook
    func addNew(call: Recent)
    func addNew(contact: Contact)
    func changeContact(in index: Dimension, with name: String, surname: String?, number: String) -> Contact
    
    func loadData(by method: Raspil)
}

class CallBookModel: CallBookModelProtocol {
    //MARK: TODO: Should use sorted array type for 'contact book'
    var contactBook: ContactBook = []{
        didSet{
            print()
            OperationQueue.main.addOperation{ [weak self] in
                self?.notifyContactsViewModel?()
            }
        }
    }
    var recentBook: RecentBook = [] {
        didSet{
            notifyRecentsViewModel?()
        }
    }
    
    var localContact: Contact?{
        didSet{
            notifyContactNodeViewModel?()
        }
    }
    func initLocal(by index: Dimension){
        localContact = contactBook[index.section][index.row]
    }
    
    func with(contactBook: ContactBook) {
        self.contactBook = contactBook
    }
    func with(recentBook: RecentBook) {
        self.recentBook = recentBook
    }
    
    var notifyContactsViewModel: (() -> ())?
    var notifyContactNodeViewModel: (() -> ())?
    var notifyRecentsViewModel: (() -> ())?
    
    func with(notifyContactsViewModel: @escaping () -> ()) -> Self{
        self.notifyContactsViewModel = notifyContactsViewModel
        return self
    }
    func with(notifyRecentsViewModel: @escaping () -> ()) -> Self{
        self.notifyRecentsViewModel = notifyRecentsViewModel
        return self
    }
    func with(notifyContactNodeViewModel: @escaping () -> ()) -> Self{
        self.notifyContactNodeViewModel = notifyContactNodeViewModel
        return self
    }
    func addNew(contact: Contact){
        contactBook.addNew(contactToBook: contact)
    }
    func changeContact(in index: Dimension, with name: String, surname: String?, number: String) -> Contact{
        contactBook.change(contactIn: index, with: name, surname: surname, number: number)
    }
    func addNew(call: Recent){
        recentBook.addNew(call: call)
    }
    func getContact(by number: String) -> Contact?{
        contactBook.findContactBy(number: number)
    }
    func deleteContact(in index: Dimension){
        contactBook.delete(index: (index.section, index.row))
    }
    func getContact(by index: Dimension) -> Contact?{
        contactBook[index.section][index.row]
    }
    func getRecentBook() -> RecentBook {
        recentBook
    }
    func getLocalContact() -> Contact? {
        localContact
    }
    func getContactBook() -> ContactBook {
        contactBook
    }
    func getRecents(by number: String) -> RecentBook {
        recentBook.findAllBy(number: number)
    }
    
    
}
