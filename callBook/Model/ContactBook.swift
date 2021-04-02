
typealias ContactBook = [[Contact]]

extension ContactBook{
    mutating func change(contactIn index: Dimension, with name: String, surname: String? = nil, number: String) -> Contact{
        return change(contact: self[index.section][index.row], with: name, surname: surname, number: number)
    }
    mutating func change(contact: Contact, with name: String, surname: String? = nil, number: String) -> Contact{
        let new = Contact(name: name, surname: surname, number: number, email: nil, birthday: nil)
        if new.getSectionName() == contact.getSectionName(){
            self.replace(old: contact, to: new)
        }else{
            delete(contact: contact)
            addNew(contactToBook: new)
        }
        return new
    }
    
    mutating func replace(old: Contact, to new: Contact){
        if let (section, row) = findIndex(of: old){
            self[section][row] = new
        }
    }
    mutating func delete(contact: Contact){
        if let index = findIndex(of: contact){
            delete(index: index)
        }
    }
    func findIndex(of contact: Contact) -> Dimension? {
        let targetSectionName = contact.getSectionName()
        
        for section in 0..<self.count{
            let sectionName = self[section][0].getSectionName()
            if sectionName == targetSectionName{
                for row in 0..<self[section].count{
                    if  self[section][row].name == contact.name,
                        self[section][row].surname == contact.surname,
                        self[section][row].number == contact.number{
                        return (section: section, row: row)
                    }
                }
            }
        }
        return nil
    }
    mutating func delete(index: Dimension){
        self[index.section].remove(at: index.row)
        if self[index.section].count == 0{
            self.remove(at: index.section)
        }
    }
    mutating func addNew(contactToBook contact: Contact){
        let sectionName = contact.getSectionName()
        for i in 0..<self.count{
            if !self[i].isEmpty, self[i][0].getSectionName() == sectionName{
                self[i].insert(contact, at: 0)
                return
            }
        }
        self.append([contact])
        abcSort()
    }
    mutating func abcSort(){
        self.sort(by: { (left, right) in left[0].getSectionName() < right[0].getSectionName() })
    }
    
    init(contacts: [Contact]){
        var contactBook: ContactBook = []
        var sectionMap = Dictionary<String, Int> ()
        for contact in contacts {
            let sectionName = contact.getSectionName()
            if let index = sectionMap[sectionName]{
                contactBook[index].append(contact)
            }else{
                contactBook.append([contact])
                sectionMap[sectionName] = sectionMap.count
            }
        }
        self.init(contactBook)
    }
    func findContactBy(number: String) -> Contact?{
        var target: Contact? = nil
        let number = number.onlyDigits()
        for section in self{
            for contact in section{
                if contact.number.onlyDigits() == number{
                    target = contact
                    return target
                }
            }
        }
        return nil
    }
}
