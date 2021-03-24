
struct MessageStorage {
    var history: [(sender: Sender, text: String)]?
    var draft: String?
}
enum Sender {
    case me
    case forMe
}
