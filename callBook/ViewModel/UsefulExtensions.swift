
import Foundation

typealias Dimension = (section: Int, row: Int)
typealias RecentViewBook = [RecentView]
typealias ContactViewsBook = [[ContactView]]
typealias ContactDataSet = (name: String, surname: String?, number: String, email: String?, birthday: DateComponents?, photo: String)
typealias ContactBook = [[Contact]]
typealias RecentBook = [Recent]

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
extension Contact {
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
