
import Foundation

struct Contact{
    var name: String
    var surname: String?
    var number: String
    var email: String?
    var birthday: DateComponents?
    var photo: String?
    var message: MessageStorage?
    
    init(name: String, surname: String?, number: String, email: String?, birthday: DateComponents?, photo: String?) {
        self.name = name
        self.surname = surname
        self.photo = photo
        self.number = number
        self.birthday = birthday
        
        self.email = email
    }
    init(name: String, surname: String?, number: String, email: String?, birthday: DateComponents?){
        self.init(name: name, surname: surname, number: number, email: email, birthday: birthday, photo: nil)
    }
    init(name: String, number: String){
        self.init(name: name, surname: nil, number: number, email: nil, birthday: nil)
    }
    mutating func with(photoByPath: String) -> Self{
        self.photo = photoByPath
        return self
    }
    mutating func with(email: String) -> Self{
        self.email = email
        return self
    }
    mutating func with(birthday: DateComponents) -> Self{
        self.birthday = birthday
        return self
    }
    
    func getShortTitle() -> String{
        var title: String
        if let surname = self.surname {
            title = "\(name.prefix(1).uppercased()) \(surname)"
        } else {
            title = name
        }
        return title
    }
    func getSectionName() -> String{
        var sectionName: String
        if let sur = surname?.prefix(1).uppercased(){
            sectionName = sur
        }else{
            sectionName = name.prefix(1).uppercased()
        }
        return sectionName
    }
}
