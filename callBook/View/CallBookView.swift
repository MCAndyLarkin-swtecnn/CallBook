
protocol ContactBookViewProtocol: class {
    var contactBook: ContactViewsBook? {get set}
    var viewModel: ContactsViewModelProtocol  {get set}
}

protocol RecentBookViewProtocol: class {
    var recentBook: RecentViewBook? {get set}
    var viewModel: RecentsViewModelProtocol  {get set}
}

struct ContactView{
    var signature: String
    var number: String
    var photo: String
    func getSectionName() -> String{
        signature.prefix(1).uppercased()
    }
}
struct RecentView{
    var title: String
    var description: String
//    var time: Int?
}
typealias ContactViewsBook = [[ContactView]]
typealias RecentViewBook = [RecentView]

//extension Recent{
//    func getRecentView() -> RecentView{
//        let time = self.time?.secondsToMinutes() ?? "Ever"
//        let abonent = findContactBy(number: self.abonent)?.getShortTitle() ?? self.abonent
//        let title = "\(time)   -   \(abonent)"
//        return RecentView(title: title, description: self.getDescription(), time: self.time)
//    }
//}
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
