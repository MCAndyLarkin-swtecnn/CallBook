
protocol CallBookView: class {
    var contactBook: ContactViewsBook? {get set}
}

struct ContactView{
    var signature: String
    var number: String
    var photo: String
    func getSectionName() -> String{
        signature.prefix(1).uppercased()
    }
}
typealias ContactViewsBook = [[ContactView]]

extension Contact{
    private static let avatarDefault = "avatar"
    func getCallBookContactView() -> ContactView{
        return ContactView(signature: getTitle(), number: number, photo: photo ?? Contact.avatarDefault)
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
