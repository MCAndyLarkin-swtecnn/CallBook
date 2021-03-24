
class Contact {
    var name: String
    var surname: String?
    var number: String
    var photo: String?
    var message: MessageStorage?
    
    init(name: String, surname: String?, number: String, photo: String?, message: MessageStorage?) {
        self.name = name
        self.surname = surname
        self.photo = photo
        self.number = number
        self.message = message
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
