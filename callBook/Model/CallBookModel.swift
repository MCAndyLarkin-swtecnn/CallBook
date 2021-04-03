
import Foundation

protocol CallBookModelProtocol{
    func getContactBook() -> ContactBook
    func getRecentBook() -> RecentBook
    
    func with(contactBook: ContactBook)
    func with(recentBook: RecentBook)
    
    func deleteContact(in index: Dimension)
    func getContact(by index: Dimension) -> Contact?
    func getContact(by number: String) -> Contact?
    func getRecents(by number: String) -> RecentBook
    func addNew(call: Recent)
    func addNew(contact: Contact)
    func changeContact(in index: Dimension, with name: String, surname: String?, number: String) -> Contact
    
    func loadData(by method: Raspil)
    func saveData()
}
class ObservableModel {
    typealias Reaction = () -> ()
    var contactBookSubscribers: [Reaction] = []
    var recentBookSubscribers: [Reaction] = []
    
    func subscribeOnContactBookChanges(reaction: @escaping Reaction) -> Self{
        contactBookSubscribers.append(reaction)
        return self
    }
    func subscribeOnRecentBookChanges(reaction: @escaping Reaction) -> Self{
        recentBookSubscribers.append(reaction)
        return self
    }
    
    func notifyContactBookSubscribers(){
        for subscriber in contactBookSubscribers{
            subscriber()
        }
    }
    func notifyRecentBookSubscribers(){
        for subscriber in recentBookSubscribers{
            subscriber()
        }
    }
}
class CallBookModel: ObservableModel, CallBookModelProtocol {
    var contactBook: ContactBook = []{
        didSet{
            OperationQueue.main.addOperation{ [weak self] in
                self?.notifyContactBookSubscribers()
            }
        }
    }
    var recentBook: RecentBook = [] {
        didSet{
            notifyRecentBookSubscribers()
        }
    }
    
    func with(contactBook: ContactBook) {
        self.contactBook = contactBook
    }
    func with(recentBook: RecentBook) {
        self.recentBook = recentBook
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
    func getContactBook() -> ContactBook {
        contactBook
    }
    func getRecents(by number: String) -> RecentBook {
        recentBook.findAllBy(number: number)
    }
    func saveData() {
    }
    func loadData(by method: Raspil) {
    }
    
}
