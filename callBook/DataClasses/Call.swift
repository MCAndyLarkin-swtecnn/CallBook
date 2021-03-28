import Foundation

struct Call{
    let abonent: String
    let io: IO
    let time: Int?
    init(abonent: String, io: IO){
        self.abonent = abonent
        self.io = io
        let time = Calendar.current.dateComponents([.minute, .hour], from: Date())
        if let hours = time.hour, let mins = time.minute{
            self.time = hours * 60 + mins
        }
        else{ self.time = nil }
    }
    func getDescription() -> String{
        var description: String
        switch  self.io{
        case .inputFail:
            description = "Missed"
        case .inputSuccess(let length):
            description = "Incoming - \(length.secondsToMinutes())"
        case .outputFail:
            description = "No responce"
        case .outputSucces(let length):
            description = "Outgoing - \(length.secondsToMinutes())"
        }
        return description
    }
}
enum IO{
    case inputSuccess(length: Int)
    case inputFail
    case outputSucces(length: Int)
    case outputFail
}
