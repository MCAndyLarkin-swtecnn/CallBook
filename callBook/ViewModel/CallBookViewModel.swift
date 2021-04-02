
import UIKit

class ViewModelSingle {
    static var viewModel: CallBookViewModel = CallBookViewModel()
}
protocol CallBookViewModelProtocol{
    var model: CallBookModel { get set }
}
protocol RecentsViewModelProtocol: CallBookViewModelProtocol {
    var uploadRecentView: (() -> ())? { get set }
    
    func getViewRecents() -> RecentViewBook
    func with(uploadRecentView: @escaping ()->()) -> Self
    func findContactBy(number: String) -> Contact?
}
protocol ContactsViewModelProtocol: CallBookViewModelProtocol {
    var uploadContactView: (() -> ())? { get set }
    
    func deleteContact(by index: Dimension)
    func makeCall(forNumberby index: Dimension)
    func loadData(method: Raspil)
    func getViewContacts() -> ContactViewsBook
    func with(uploadContactView: @escaping ()->()) -> Self
    func addNew(call: Recent)
}
class CallBookViewModel: RecentsViewModelProtocol, ContactsViewModelProtocol {
    lazy var model: CallBookModel = CallBookModel(notifyContactsViewModel: {
        self.uploadContactView?()
    }, notifyRecentsViewModel: {
        self.uploadRecentView?()
    })
    
    
    internal var uploadRecentView: (() -> ())?
    internal var uploadContactView: (() -> ())?
    
    
    func with(uploadRecentView: @escaping () -> ()) -> Self {
        self.uploadRecentView = uploadRecentView
        return self
    }
    func with(uploadContactView: @escaping () -> ()) -> Self {
        self.uploadContactView = uploadContactView
        return self
    }

    func getViewContacts() -> ContactViewsBook {
        model.contactBook.map{ section in
            section.map{ contact in
                contact.getContactView()
            }
        }
    }
    func getViewRecents() -> RecentViewBook {
        model.recentBook.map{
            recent in
            let time = recent.time?.secondsToMinutes() ?? "Sometime"
            let abonent = findContactBy(number: recent.abonent)?.getShortTitle() ?? recent.abonent
            let title = "\(time)   -   \(abonent)"
            return RecentView(title: title, description: recent.getDescription())
        }
    }

    func deleteContact(by index: Dimension) {
        model.contactBook.delete(index: (index.section, index.row))
        uploadContactView?()
    }
    
    //MARK:  Who must make call?
    func makeCall(forNumberby index: Dimension) {
        let number = model.contactBook[index.section][index.row].number.onlyDigits()
        if let url = URL(string: "tel://\(number)"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        addNew(call: Recent(abonent: number, io: .outputFail))
    }
    
    func loadData(method: Raspil) {
        model.loadData(by: method)
    }
    func findContactBy(number: String) -> Contact? {
        model.contactBook.findContactBy(number: number)
    }
    func addNew(call: Recent) {
        model.recentBook.addNew(call: call)
    }
}
