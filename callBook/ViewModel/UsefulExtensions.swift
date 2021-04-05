
import Foundation

typealias Dimension = (section: Int, row: Int)
typealias RecentViewBook = [RecentView]
typealias ContactViewsBook = [[ContactView]]
typealias ContactDataSet = (name: String, surname: String?, number: String, email: String?, birthday: DateComponents?, photo: String)
typealias ContactBook = [[Contact]]
typealias RecentBook = [Recent]
typealias BirthdayLog = [DateComponents.CodableDate: [FullName]]

extension DateComponents{
    struct CodableDate: Codable, Hashable{
        let day: Int
        let month: Int
        static func == (lhs: CodableDate, rhs: CodableDate) -> Bool {
            return lhs.month == rhs.month && lhs.day == rhs.day
        }
        static func < (lhs: CodableDate, rhs: CodableDate) -> Bool {
            if rhs.month == lhs.month {
                return rhs.day > lhs.day
            }else{
                return rhs.month > lhs.month
            }
        }
    }
    func getCodable() -> CodableDate?{
        if let day = self.day, let month = self.month{
            return CodableDate(day: day, month: month)
        }
        return nil
    }
}
extension String {
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
extension Int {
    func secondsToMinutes() -> String{
        return "\(Int(self/60)):\( { () -> String in var secs = String(self % 60); if secs.count == 1 { secs = "0\(secs)" }; return secs}())"
    }
}
extension Contact{
    struct CodingData: Codable {
        var firstname: String
        var lastname: String
        var phone: String
        var email: String
        var contact: Contact {
            return Contact(
                name: firstname,
                surname: lastname,
                number: phone,
                email: email,
                birthday: nil
            )
        }
    }
    func getCodable() -> CodableContact{
        CodableContact(contact: self)
    }
    struct CodableContact:Codable{
        var name: String
        var surname: String?
        var number: String
        var email: String?
        var birthday: DateComponents?
        var photo: String?
        init(contact: Contact) {
            name = contact.name
            surname = contact.surname
            number = contact.number
            email = contact.email
            birthday = contact.birthday
            photo = contact.photo
        }
        var contact: Contact{
            Contact(name: name, surname: surname, number: number, email: email, birthday: birthday, photo: photo)
        }
    }

}
extension String: Error{ }
extension RecentView{
    init(recent: Recent) {
        self.init(time: recent.time?.secondsToMinutes() ?? "Sometime", abonent: recent.abonent, description: recent.getDescription())
    }
}
extension Contact{
    func getContactView() -> ContactView{
        ContactView(signature: getTitle(), number: number, photo: photo ?? ContactView.avatarDefault)
    }
    func getTitle() -> String{
        FullName(name: name, surname: surname).getTitle()
    }
}
extension IndexPath{
    func onlyCoords() -> Dimension{
        (section: self.section, row: self.row)
    }
}

struct ContactView{
    static let avatarDefault = "avatar"
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
struct FullName: Codable{
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
    init(name: String, surname: String?) {
        self.name = name
        self.surname = surname
    }
    init(dataSet: ContactDataSet) {
        name = dataSet.name
        surname = dataSet.surname
    }
}

extension Contact{
    func getDataSet() -> ContactDataSet{
        return (name: name, surname: surname, number: number, email: email, birthday: birthday, photo: photo ?? ContactView.avatarDefault)
    }
}
