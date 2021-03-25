import Dispatch
import Foundation

//протоколы
class Manager{
    public var contactBook : [[Contact]] = []
    public var callLog: [Call] = []
    private var upload: (()->())?
    
    public func checkDataToLog(){
        for section in contactBook{
            for contact in section{
                print("\(contact.name), - \(contact.number)")
            }
        }
    }
    public func andLoadDefaultData() -> Self{
        contactBook = [
            [Contact(name: "Anya", surname: nil, number: "89235416217", email: nil, photo: nil , message: MessageStorage(
                history: [
                    (Sender.forMe, "hi"),
                    (Sender.me, "hello"),
                    (Sender.forMe, "What's up?")
                ],
                draft: "It's OK! You?"
            )
            )
            ],
            [Contact(name: "Manya", surname: "Chekhova", number: "89235445645", email: nil).with(photoByPath: "sova")],
            [
             Contact(name: "Sanya", surname: "Solzhenitsin", number: "89346346657", email: nil).with(photoByPath: "puh"),
             Contact(name: "Maxim", surname: "Sokolov", number: "89056648000", email: nil).with(photoByPath: "krolik")
            ],
            [Contact(name: "Danya", surname: "Esenin", number: "89257345723", email: nil).with(photoByPath: "svin")]
        ]
        callLog = [
            Call(abonent: "89235416217", io: IO.inputSuccess(length: 2541), time: 143 ),
            Call(abonent: "89235445645", io: IO.inputSuccess(length: 1941), time: 143 ),
            Call(abonent: "89346346657", io: IO.inputFail, time: 321),
            Call(abonent: "89235416217", io: IO.inputSuccess(length: 542), time: 213 ),
            Call(abonent: "89056648000", io: IO.outputSucces(length:1288), time: 452),
            Call(abonent: "89257345723", io: IO.outputFail, time: 145)
        ]
        return self
    }
    public func andLoadData() -> Self{
        let sem = DispatchSemaphore(value: 0)
        var encodedContacts: [Contact] = []
        let method: Raspil = .gcd
        switch method {
        case .gcd:
            guard let url = URL( string: "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json")else {
                return self
            }
            DispatchQueue.global(qos: .background).async {
                URLSession.shared.dataTask(
                    with: URLRequest( url: url ) ) { (data, response, error) in
                    defer {
                        sem.signal()
                    }
                    guard let data = data else {
                        return
                    }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    if let decoded = try? decoder.decode([Contact.CodingData].self, from: data){
                        encodedContacts = decoded.map({(it) in it.contact})
                    }

                    self.createCallBookBy(contacts: encodedContacts)

                    if let upload = self.upload{
                        DispatchQueue.main.async(execute: upload)
                    }
                }.resume()
            }
        case .operations:
            break
        }
        return self
    }
    func withUpload( upload: @escaping ()->() ) -> Self{
        self.upload = upload
        return self
    }
    func createCallBookBy(contacts: [Contact]){
        var sectionMap: Dictionary<String, Int> = [:]
        var num = 0
        for contact in contacts {
            let sectionName = contact.getSectionName()
            if let index = sectionMap[sectionName]{
                contactBook[index].append(contact)
            }else{
                contactBook.append([contact])
                sectionMap[sectionName] = num
                num += 1
            }
        }
        //contactBook change
    }
    func findAllCallsBy(numberForSearching number: String) -> [Call] {
        let clearNumber = number.onlyDigits()
        var listToReturn: [Call] = []
        
        for call in callLog{
            if call.abonent == clearNumber{
                listToReturn.append(call)
            }
        }
        return listToReturn
    }
    ///callLog is not sorted yet so it just return nearest in list
    func findLastCallBy(numberForSearching number: String) -> Call?{
        return self.callLog.findLast(byNumber: number)
    }
    func findContactBy(numberForSearching number: String) -> Contact?{
        var target: Contact? = nil
        let number = number.onlyDigits()
        for section in contactBook{
            for contact in section{
                if contact.number.onlyDigits() == number{
                    target = contact
                    break
                }
            }
        }
        return target
    }
    func findIndexOf(contactInCoontactBook contact: Contact) -> (section: Int, row: Int)?{
        let targetSectionName = contact.getSectionName()
        var target: (Int, Int)? = nil
        
        for section in 0..<contactBook.count{
            let sectionName = contactBook [section][0].getSectionName()
            if sectionName == targetSectionName{
                for row in 0..<contactBook[section].count{
                    if  contactBook[section][row].name == contact.name,
                        contactBook[section][row].surname == contact.surname,
                        contactBook[section][row].number == contact.number{
                        target = (section, row)
                    }
                }
            }
        }
        return target
    }
    func change(contact: Contact, name: String? = nil, surname: String? = nil, number: String? = nil){
        if let indexof = findIndexOf(contactInCoontactBook: contact){
            let contact = contactBook[indexof.section][indexof.row]
            if let newName = name{
                contact.name = newName
            }
            if let newNumber = number{
                contact.number = newNumber
            }
            contact.surname = surname
        }
    }
    func addNew(callToLog call:Call){
        callLog.insert(call, at: 0)
    }
    func delete(index: (section: Int, row: Int)){
        contactBook[index.section].remove(at: index.row)
        if contactBook[index.section].count == 0{
            contactBook.remove(at: index.section)
        }
    }
    func addNew(contactToBook contact: Contact){
        let sectionName = contact.getSectionName()
        
        for i in 0..<contactBook.count{
            let section: String
            if let sur = contactBook [i][0].surname?.prefix(1).uppercased(){
                section = sur
            }else{
                section = contactBook [i][0].name.prefix(1).uppercased()
            }
            if section == sectionName{
                contactBook [i].append(contact)
                return
            }
        }
        contactBook.append([contact])
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
                email: email
            )
        }
    }
}
enum Raspil{
    case gcd
    case operations
}
