//
//protocol ContactBookViewProtocol: class {
//    var contactBook: ContactViewsBook? {get set}
//    var viewModel: ContactsViewModelProtocol  {get set}
//}
//protocol RecentBookViewProtocol: class {
//    var recentBook: RecentViewBook? {get set}
//    var viewModel: RecentsViewModelProtocol {get set}
//}
//protocol LocalContactViewProtocol: class {
//    var localContact: ContactDataSet? {get set}
//    var viewModel: LocalContactViewModel {get set}
//}

struct ContactView{
    var signature: String
    var number: String
    var photo: String
    func getSectionName() -> String{
        signature.prefix(1).uppercased()
    }
}
struct RecentView{
    var time: String
    var abonent: String
    var description: String
    func getTitle() -> String {
        "\(time)   -   \(abonent)"
    }
}
typealias ContactViewsBook = [[ContactView]]
typealias RecentViewBook = [RecentView]
extension RecentView{
    init(recent: Recent) {
        self.init(time: recent.time?.secondsToMinutes() ?? "Sometime", abonent: recent.abonent, description: recent.getDescription())
    }
}
extension Contact{
    private static let avatarDefault = "avatar"
    func getContactView() -> ContactView{
        ContactView(signature: getTitle(), number: number, photo: photo ?? Contact.avatarDefault)
    }
    func getTitle() -> String{
        let surname: String
        if let sur = self.surname{
            surname = "\(sur) "
        }else{
            surname = ""
        }
        return surname + name
    }
}
struct FullName{
    var name: String
    var surname: String?
    func getTitle() -> String{
        let surname: String
        if let sur = self.surname{
            surname = "\(sur) "
        }else{
            surname = ""
        }
        return surname + name
    }
    init(dataSet: ContactDataSet) {
        name = dataSet.name
        surname = dataSet.surname
    }
}
