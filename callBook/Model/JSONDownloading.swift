import Foundation

var link = "https://gist.githubusercontent.com/artgoncharov/61c471db550238f469ad746a0c3102a7/raw/590dcd89a6aa10662c9667138c99e4b0a8f43c67/contacts_data2.json"

class FileManagedModel: CallBookModel {
    //MARK: JSON Maining
    override func saveData() {
        if let fileURL = FileManager().urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(contactsDataDirectoryName).appendingPathComponent(contactsBookFileName),
           let data = getDatabyContactBook(){
            do {
                try data.write(to: fileURL)
            } catch {
                print("creatingAndWriteError")
            }
        }
    }
    func getDatabyContactBook() -> Data?{
        let codableContactBook = contactBook.map{
            section in section.map{
                contact in contact.getCodable()
            }
        }
        let encoder = JSONEncoder()
        return try? encoder.encode(codableContactBook)
    }
    override func loadDataFromFileSystem() {
        if let fileURL = FileManager().urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(contactsDataDirectoryName).appendingPathComponent(contactsBookFileName){
            do {
                parseAndPutContacts(data: try Data(contentsOf: fileURL), sectioned: true)
            } catch {
                print("readingError")
            }
        }
    }
    func downloadContacts() throws -> Data{
        let sem = DispatchSemaphore(value: 0)
        var dataToOut: Data?
        
        if let url = URL(string: link){
            URLSession.shared.dataTask(
                with: URLRequest( url: url ) ) { data, _, _ in
                
                defer {
                    sem.signal()
                }
                dataToOut = data
            }.resume()
        }
        guard sem.wait(timeout: .now() + .seconds(30)) == .success else{
            throw "Failed waiting"
        }
        guard let data = dataToOut else {
            throw "Failed request"
        }
        return data
    }
    
    override func loadData(by method: Raspil){
        let processing = {
            do{
                self.parseAndPutContacts(data: try self.downloadContacts(), sectioned: false)
            }catch{
                print(error)
            }
        }
        
        switch method {
        case .gcd:
            DispatchQueue.global(qos: .utility).async(execute: processing)
        case .operations:
            OperationQueue().addOperation(processing)
        }
    }
    func parseAndPutContacts(data: Data, sectioned: Bool){
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        if sectioned{
            guard let decoded = try? decoder.decode([[Contact.CodableContact]].self, from: data)
            else { return }
            with(contactBook: decoded.map{
                section in section.map{
                    cont in cont.contact
                }
            })
        }else{
            guard let decoded = try? decoder.decode([Contact.CodingData].self, from: data)
            else { return }
            with(contactBook: ContactBook( contacts: decoded.map({(it) in it.contact}) ) )
            contactBook.abcSort()
        }
        
    }
    
}

//MARK: enum Raspil
enum Raspil{
    case gcd
    case operations
}
enum DataSource{
    case network(method: Raspil)
    case fileSystem
}
