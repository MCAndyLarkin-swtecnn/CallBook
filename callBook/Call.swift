

struct Call{
    let abonent: String
    let io: IO
    let time: Int}
enum IO{
    case inputSuccess(length: Int)
    case inputFail
    case outputSucces(length: Int)
    case outputFail
}
