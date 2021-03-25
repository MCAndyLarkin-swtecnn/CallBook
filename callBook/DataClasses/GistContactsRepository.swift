
import UIKit

protocol ContactsRepository {
    func getContacts() throws -> [Contact]
}

enum Raspil{
    case gcd
    case operations
}

class GistConstactsRepository: ContactsRepository {
    let timeout: UInt64 = 1000000000
    private let path: String
    init(path: String) {
        self.path = path
    }
    func getContacts() throws -> [Contact] {
        let sem = DispatchSemaphore(value: 0)
        let request = URLRequest(url: URL(string: "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json")!)
        var result: [Contact] = []
        let method: Raspil = .gcd
        switch method {
        case .gcd:
            DispatchQueue(label: "com.bestkora.workerQueue1",  qos: .userInitiated, attributes: .concurrent).async {
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    defer {
                        sem.signal()
                    }
                    //  MARK: TODO: handle error
                    guard let data = data else {
                        print("Error")
                        return
                    }
                    
                    // MARK: TODO:  parse data
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    if let decoded = try? decoder.decode([Contact.CodingData].self, from: data){
                        result = decoded.map({(it) in it.contact})
                        print("Successeful translation: \(result.count)")
                    }
                    
                }
                task.resume()
                print(sem.wait(timeout: DispatchTime(uptimeNanoseconds: self.timeout)) )
            }
            return result
        case .operations:
            break
        }
        
        
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
