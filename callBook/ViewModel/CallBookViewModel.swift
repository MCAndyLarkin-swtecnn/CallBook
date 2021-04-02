
import UIKit

class ViewModelSingle {
    static var viewModel: CallBookViewModel = CallBookViewModel()
}
protocol CallBookViewModelProtocol{
    var model: CallBookModelProtocol { get set }
}
protocol RecentsViewModelProtocol: CallBookViewModelProtocol {
    var uploadRecentView: (() -> ())? { get set }
    
    func getViewRecents() -> RecentViewBook
    func with(uploadRecentView: @escaping ()->()) -> Self
}
protocol ContactsViewModelProtocol: CallBookViewModelProtocol {
    var uploadContactView: (() -> ())? { get set }
    
    func deleteContact(by index: Dimension)
    func makeCall(forNumberby index: Dimension)
    func loadData(method: Raspil)
    func getViewContacts() -> ContactViewsBook
    func with(uploadContactView: @escaping ()->()) -> Self
    func addNew(call: Recent)
    func addNewContactBy(_ dataSet: ContactDataSet?)
}

protocol ContactNodeViewModel: CallBookViewModelProtocol {
    var uploadContactNodeData: (() -> ())? { get set }
    func with(uploadContactNodeData: @escaping ()->()) -> Self
    
    func change(contactIn: Dimension, with name: String, surname: String?, number: String) -> ContactDataSet
    func getLocalContact(by index: Dimension) -> ContactDataSet?
    func initial(by index: Dimension)
}

class CallBookViewModel: RecentsViewModelProtocol, ContactsViewModelProtocol, ContactNodeViewModel {
    
    internal lazy var model: CallBookModelProtocol = CallBookModel().with(notifyContactsViewModel: { [weak self] in
        self?.uploadContactView?()
    }).with(notifyRecentsViewModel: { [weak self] in
        self?.uploadRecentView?()
    }).with(notifyContactNodeViewModel: { [weak self] in
        self?.uploadContactNodeData?()
    })
    
    internal var uploadRecentView: (() -> ())?
    internal var uploadContactView: (() -> ())?
    internal var uploadContactNodeData: (() -> ())?
    
    
    func with(uploadContactNodeData: @escaping ()->()) -> Self{
        self.uploadContactNodeData = uploadContactNodeData
        return self
    }
    func with(uploadRecentView: @escaping () -> ()) -> Self {
        self.uploadRecentView = uploadRecentView
        return self
    }
    func with(uploadContactView: @escaping () -> ()) -> Self {
        self.uploadContactView = uploadContactView
        return self
    }

    func getViewContacts() -> ContactViewsBook {
        model.getContactBook().map{ section in
            section.map{ contact in
                contact.getContactView()
            }
        }
    }
    func getViewRecents() -> RecentViewBook {
        model.getRecentBook().map{
            recent in
            let time = recent.time?.secondsToMinutes() ?? "Sometime"
            let abonent = findContactBy(number: recent.abonent)?.getShortTitle() ?? recent.abonent
            let title = "\(time)   -   \(abonent)"
            return RecentView(title: title, description: recent.getDescription())
        }
    }

    func deleteContact(by index: Dimension) {
        model.deleteContact(in: index)
    }
    
    //MARK:  Who must make call?
    func makeCall(forNumberby index: Dimension) {
        
        if let number = model.getContact(by: index)?.number.onlyDigits(),
           let url = URL(string: "tel://\(number)"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            addNew(call: Recent(abonent: number, io: .outputFail))
        }
    }
    
    func loadData(method: Raspil) {
        model.loadData(by: method)
    }
    func findContactBy(number: String) -> Contact? {
        model.getContact(by: number)
    }
    internal func addNew(call: Recent) {
        model.addNew(call: call)
    }
    
    func addNewContactBy(_ dataSet: ContactDataSet?) {
        //MARK: IT IS NECESSARY??
        if let dataSet = dataSet{
            model.addNew(contact:
                                    Contact(name: dataSet.name,
                                            surname: dataSet.surname,
                                            number: dataSet.number,
                                            email: dataSet.email,
                                            birthday: dataSet.birthday,
                                            photo: dataSet.photo)
                                        )
        }
        
    }
    func change(contactIn index: Dimension, with name: String, surname: String?, number: String) -> ContactDataSet{
        model.changeContact(in: index, with: name, surname: surname, number: number).getDataSet()
    }
    
    func initial(by index: Dimension) {
        model.initLocal(by: index)
    }
    
    func getLocalContact(by index: Dimension) -> ContactDataSet? {
        model.getLocalContact()?.getDataSet()
    }
}
