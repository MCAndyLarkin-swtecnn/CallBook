import UIKit

extension Array where Element == Call{
    func findLast(byNumber number: String?) -> Call?{
        guard let number = number else {
            return nil
        }
        let clearNumber = number.onlyDigits()
        var target: Call? = nil
        
        for call in self{
            if call.abonent.onlyDigits() == clearNumber{
                target = call
                break
            }
        }
        return target
    }
}
extension String {
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
extension Int {
    func secondsToMinutes() -> String{
        return "\(Int(self/60)):\( { () -> String in var secs = String(self % 60); if secs.count == 1 { secs = "\(secs)0" }; return secs}())"
    }
}