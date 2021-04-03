
extension RecentBook{
    func findLast(byNumber number: String) -> Recent?{
        let clearNumber = number.onlyDigits()
        var target: Recent? = nil
        
        for call in self{
            if call.abonent.onlyDigits() == clearNumber{
                target = call
                break
            }
        }
        return target
    }
    func findAllBy(number: String) -> [Recent] {
        let clearNumber = number.onlyDigits()
        var listToReturn: [Recent] = []
        
        for call in self{
            if call.abonent == clearNumber{
                listToReturn.append(call)
            }
        }
        return listToReturn
    }
    mutating func addNew(call:Recent){
        self.insert(call, at: 0)
    }
}
