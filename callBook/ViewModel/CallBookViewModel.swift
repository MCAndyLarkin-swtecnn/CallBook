
import UIKit

protocol CallBookViewModelProtocol{
    var model: CallBookModelProtocol { get }
}
protocol RecentsViewModelProtocol: CallBookViewModelProtocol {
    func getViewRecents() -> RecentViewBook
}
protocol ContactsViewModelProtocol: CallBookViewModelProtocol {
    var birthdayLog: BirthdayLog {get}
    
    var uploadContactView: (() -> ())? { get }
    var selebratingFor: ((FullName) -> ())? { get }
    
    func deleteContact(by index: Dimension)
    func makeCall(forNumberby index: Dimension)
    func loadData(source: DataSource)
    func saveData()
    func getViewContacts() -> ContactViewsBook
    func with(uploadContactView: @escaping ()->()) -> Self
    func with(selebrating: @escaping (FullName)->()) -> Self
    func checkBirthdayLog() 
    func addNew(call: Recent)
    func addNewContactBy(_ dataSet: ContactDataSet?)
}

protocol LocalContactViewModel: CallBookViewModelProtocol {
    var localContact: Contact? {get}
    var index: Dimension? {get}
    
    var uploadRecent: (() -> ())? { get }
    var uploadFace: (() -> ())? { get }
    func with(uploadRecent: @escaping ()->()) -> Self
    func with(uploadFace: @escaping ()->()) -> Self
    
    func getViewRecents(for number: String) -> RecentViewBook
    func changeContact(name: String, surname: String?, number: String) -> ContactDataSet?
    
    func initLocal(by index: Dimension)
    func unbindLocal()
    func getLocalContact() -> ContactDataSet?
    
    func makeCall(by number: String)
}


class ViewModelSingle {
    static var viewModel = CallBookViewModel()
    class CallBookViewModel: RecentsViewModelProtocol, ContactsViewModelProtocol, LocalContactViewModel {
        var birthdayLog: BirthdayLog = [:]
        
        internal lazy var model: CallBookModelProtocol = FileManagedModel()
            .subscribeOnContactBookChanges{ [weak self] in
                self?.uploadContactView?()
                if self?.localContact != nil{
                    self?.uploadFace?()
                }
            }
            .subscribeOnRecentBookChanges {[weak self] in
                if self?.localContact != nil{
                    self?.uploadRecent?()
                }
            }
        
        var index: Dimension?
        var localContact: Contact?
        
        func initLocal(by index: Dimension) {
            self.index = index
            localContact = model.getContact(by: index)
        }
        
        func unbindLocal() {
            index = nil
            localContact = nil
        }
        
        func getLocalContact() -> ContactDataSet? {
            localContact?.getDataSet()
        }
        func changeContact(name: String, surname: String?, number: String) -> ContactDataSet? {
            guard let index = index
            else{ return nil }
            localContact = model.changeContact(in: index, with: name, surname: surname, number: number)
            guard let contact = model.getContact(by: number)  else {
                self.index = nil
                return nil
            }
            self.index = model.getContactBook().findIndex(of: contact)
            return localContact?.getDataSet()
        }
        
        internal var uploadContactView: (() -> ())?
        internal var uploadRecent: (() -> ())?
        internal var uploadFace: (() -> ())?
        internal var selebratingFor: ((FullName) -> ())?
            
        func with(uploadRecent: @escaping ()->()) -> Self{
            self.uploadRecent = uploadRecent
            return self
        }
        func with(uploadFace: @escaping ()->()) -> Self{
            self.uploadFace = uploadFace
            return self
        }
        func with(uploadContactView: @escaping () -> ()) -> Self {
            self.uploadContactView = uploadContactView
            return self
        }
        func with(selebrating: @escaping (FullName) -> ()) -> Self {
            selebratingFor = selebrating
            return self
        }
        func checkBirthdayLog() {
            let today = Calendar.current.dateComponents([.day, .month], from: Date())
            birthdayLog
                .first(where: {
                date, _ in
                date.day == today.day && date.month == today.month
            })?.value
                .forEach{
                man in
                selebratingFor?(man)
            }
        }

        func getViewContacts() -> ContactViewsBook {
            model.getContactBook().map{ section in
                section.map{ contact in
                    contact.getContactView()
                }
            }
        }
        func getViewRecents(for number: String) -> RecentViewBook {
            model.getRecents(by: number).map{
                call in RecentView(recent: call)
            }
        }
        
        func getViewRecents() -> RecentViewBook {
            model.getRecentBook().map{
                recent in
                let time = recent.time?.secondsToMinutes() ?? "Sometime"
                let abonent = findContactBy(number: recent.abonent)?.getShortTitle() ?? recent.abonent
                return RecentView(time: time, abonent: abonent, description: recent.getDescription())
            }
        }

        func deleteContact(by index: Dimension) {
            model.deleteContact(in: index)
        }
        
        //MARK:  Who must make call?
        func makeCall(forNumberby index: Dimension) {
            if let number = model.getContact(by: index)?.number.onlyDigits(){
                makeCall(by: number)
            }
        }
        func makeCall(by number: String) {
            if let url = URL(string: "tel://\(number)"){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                addNew(call: Recent(abonent: number, io: .outputFail))
            }
        }
        
        func loadData(source: DataSource) {
            switch source {
            case .network(let method):
                model.loadData(by: method)
            case .fileSystem:
                model.loadDataFromFileSystem()
                loadBirthdayData()
                checkBirthdayLog()
            }
        }
        func findContactBy(number: String) -> Contact? {
            model.getContact(by: number)
        }
        internal func addNew(call: Recent) {
            model.addNew(call: call)
        }
        
        func saveData() {
            model.saveData()
            saveBirthdayData()
        }
        func saveBirthdayData(){
            if let fileURL = FileManager().urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(contactsDataDirectoryName).appendingPathComponent(birthdaysFileName),
               let data = try? JSONEncoder().encode(birthdayLog){
                do {
                    try data.write(to: fileURL)
                } catch {
                    print("creatingAndWriteError")
                }
            }
        }
        func loadBirthdayData(){
            if let fileURL = FileManager().urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(contactsDataDirectoryName).appendingPathComponent(birthdaysFileName){
                if let data = try? Data(contentsOf: fileURL),
                   let decoded = try? JSONDecoder().decode(BirthdayLog.self, from: data){
                    birthdayLog = decoded
                }
            }
        }
        
        func addNewContactBy(_ dataSet: ContactDataSet?) {
            //MARK: IT IS NECESSARY??
            if let dataSet = dataSet{
                let contact = Contact(name: dataSet.name,
                                      surname: dataSet.surname,
                                      number: dataSet.number,
                                      email: dataSet.email,
                                      birthday: dataSet.birthday,
                                      photo: dataSet.photo)
                model.addNew(contact: contact)
                
                if let birthday = contact.birthday?.getCodable(){
                    if birthdayLog[birthday] == nil{
                        birthdayLog[birthday] = []
                    }
                    birthdayLog[birthday]?.append(FullName(dataSet:  contact.getDataSet()))
                    checkBirthdayLog()
                }
            }
            
        }
    }

}
