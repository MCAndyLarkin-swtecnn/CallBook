
import Foundation

protocol CallBookModel {
    var viewModel: CallBookViewModelProtocol {get set}
    init(viewModel: CallBookViewModelProtocol)
}

class Manager: CallBookModel{
    //MARK: Data
    //TODO: Should use sorted array type for 'contact book'
    public var contactBook : ContactBook = []
    public var callLog: [Call] = []
    
    //MARK: MVVM
    var viewModel: CallBookViewModelProtocol
    
    required init(viewModel: CallBookViewModelProtocol) {
        self.viewModel = viewModel
        self.loadData(by: .gcd)
    }
    
    //MARK: JSON Maining
    private var url = URL( string: "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json")
    
    func downloadContacts() throws -> Data{
        let sem = DispatchSemaphore(value: 0)
        var dataToOut: Data?
        
        if let url = self.url{
            URLSession.shared.dataTask(
                with: URLRequest( url: url ) ) { data, _, _ in
                
                defer {
                    sem.signal()
                }
                dataToOut = data
            }.resume()
        }
        guard sem.wait(timeout: .now() + .seconds(7)) == .success else{
            throw "Failed waiting"
        }
        guard let data = dataToOut else {
            throw "Failed request"
        }
        return data
    }
    
    func loadData(by method: Raspil){
        let processing = {
            do{
                self.parseAndPutData(data: try self.downloadContacts() )
            }catch{
                print(error)
            }
        }
        let upload: ()->() = { [weak self] in
            self?.viewModel.notifyToChangesInModel()
        }
        switch method {
        case .gcd:
            DispatchQueue.global(qos: .utility).async{
                processing()
                DispatchQueue.main.async(execute: upload)
            }
        case .operations:
            let processingOperation = BlockOperation(block: processing)
                processingOperation.completionBlock = {
                    OperationQueue.main.addOperation(upload)
                }
            OperationQueue().addOperation(processingOperation )
        }
    }
    func parseAndPutData(data: Data){
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let decoded = try? decoder.decode([Contact.CodingData].self, from: data)
        else { return }
        
        createCallBookBy( contacts: decoded.map({(it) in it.contact}) )
        abcSort()
    }
    
    //MARK: Data Service
    
    func createCallBookBy(contacts: [Contact]){
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
    
    ///callLog is not sorted yet so it just return one nearest in list
    func findLastCallBy(numberForSearching number: String) -> Call?{
        //TODO: Make reusable named calls storage
        //TODO: Make named storage after adding (in backgroung), not in loadData process
        // O(n) is bad way
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
    
    func change(contact: Contact, with name: String, surname: String? = nil, number: String) -> Contact{
        delete(contact: contact)
        let new = Contact(name: name, surname: surname, number: number, email: nil, birthday: nil)
        addNew(contactToBook: new)
        return new
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
    
    func delete(contact: Contact){
        let targetSectionName = contact.getSectionName()
        
        for section in 0..<contactBook.count{
            let sectionName = contactBook [section][0].getSectionName()
            if sectionName == targetSectionName{
                for row in 0..<contactBook[section].count{
                    if  contactBook[section][row].name == contact.name,
                        contactBook[section][row].surname == contact.surname,
                        contactBook[section][row].number == contact.number{
                        delete(index: (section, row))
                        return
                    }
                }
            }
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
                contactBook[i].insert(contact, at: 0)
                return
            }
        }
        contactBook.append([contact])
        abcSort()
    }
    func abcSort(){
        self.contactBook.sort(by: { (left, right) in left[0].getSectionName() < right[0].getSectionName() })
    }
}

//MARK: enum Raspil
enum Raspil{
    case gcd
    case operations
}

