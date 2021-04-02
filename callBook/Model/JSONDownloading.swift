import Foundation

var link = "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json"

extension CallBookModel{
    //MARK: JSON Maining
    
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
        
        switch method {
        case .gcd:
            DispatchQueue.global(qos: .utility).async(execute: processing)
        case .operations:
            OperationQueue().addOperation(processing)
        }
    }
    func parseAndPutData(data: Data){
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let decoded = try? decoder.decode([Contact.CodingData].self, from: data)
        else { return }
        
        contactBook = ContactBook( contacts: decoded.map({(it) in it.contact}) )
        contactBook.abcSort()
    }
    
}

//MARK: enum Raspil
enum Raspil{
    case gcd
    case operations
}

