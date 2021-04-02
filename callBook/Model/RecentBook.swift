
typealias RecentBook = [Recent]
extension RecentBook{
    ///callLog is not sorted yet so it just return one nearest in list
    func findLast(byNumber number: String) -> Recent?{
        //TODO: Make reusable named calls storage
        //TODO: Make named storage after adding (in backgroung), not in loadData process
        // O(n) is bad way
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
