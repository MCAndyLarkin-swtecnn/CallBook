
struct Call{
    let abonent: String
    let io: IO
    let time: Int
    
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
