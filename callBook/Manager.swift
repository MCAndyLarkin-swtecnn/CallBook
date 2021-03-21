//
//  Manager.swift
//  callBook
//
//  Created by user on 21.03.2021.
//

import UIKit

class Manager{  
    public var contactBook : [[Contact]] = []
    public var callLog: [Call] = []
    
    public func checkDataToLog(){
        for section in contactBook{
            for contact in section{
                print("\(contact.name), - \(contact.number)")
            }
        }
    }
    
    public func loadData(){
        contactBook = [
            [Contact(name: "Anya", surname: nil, number: "89235416217", photo: nil , message: MessageStorage(
                history: [
                    (Sender.forMe, "hi"),
                    (Sender.me, "hello"),
                    (Sender.forMe, "What's up?")
                ],
                draft: "It's OK! You?"
            )
            )
            ],
            [Contact(name: "Manya", surname: "Chehova", number: "8 (923) 544-56-45", photo: "sova", message: nil )],
            [
             Contact(name: "Sanya", surname: "Solzhenitsin", number: "8 (934) 634-66-57", photo: "puh", message: nil  ),
             Contact(name: "Maxim", surname: "Sokolov", number: "8 (905) 664-80-00", photo: "krolik", message: nil  )
            ],
            [Contact(name: "Danya", surname: "Esenin", number: "8 (925) 734-57-23", photo: "svin", message: nil  )]
        ]
        
        callLog = [
            Call(abonent: "89235416217", io: IO.inputSuccess(length: 2541), time: 143 ),
            Call(abonent: "89235445645", io: IO.inputSuccess(length: 1941), time: 143 ),
            Call(abonent: "89346346657", io: IO.inputFail, time: 321),
            Call(abonent: "89235416217", io: IO.inputSuccess(length: 542), time: 213 ),
            Call(abonent: "89056648000", io: IO.outputSucces(length:1288), time: 452),
            Call(abonent: "89257345723", io: IO.outputFail, time: 145)
        ]
    }
    
    func findAllCallsByNumber(numberForSearching number: String) -> [Call] {
        let clearNumber = number.onlyDigits()
        var listToReturn: [Call] = []
        
        for call in callLog{
            if call.abonent == clearNumber{
                listToReturn.append(call)
            }
        }
        return listToReturn
    }
    ///callLog is not sorted yet so it just return nearest in list
    func findLastCallByNumber(numberForSearching number: String) -> Call?{
        return self.callLog.findLast(byNumber: number)
    }
    func findNameByNumber(numberForSearching number: String) -> String?{
        var target: String? = nil
        
        for section in contactBook{
            for contact in section{
                if contact.number == number{
                    target = contact.name
                    break
                }
            }
        }
        return target
    }
    func addNew(callToLog call:Call){
        let newCall = Call(abonent: call.abonent.onlyDigits(), io: call.io, time: call.time)
        callLog.append(newCall)
    }
    func addNew(contactToBook contact: Contact){
        var sectionName: String

        if let sur = contact.surname{
            sectionName = String(sur.prefix(1)).uppercased()
        }else{
            sectionName = String(contact.name.prefix(1)).uppercased()
        }
        
        for i in 0..<contactBook.count{
            print("\(sectionName) ~ \(contactBook [i][0].name.prefix(1).uppercased())")
            let section: String
            if let sur = contactBook [i][0].surname?.prefix(1).uppercased(){
                section = sur
            }else{
                section = contactBook [i][0].name.prefix(1).uppercased()
            }
            if section == sectionName{
                contactBook [i].append(contact)
                return
            }
        }
        contactBook.append([contact])
    }
    
}

extension Array where Element == Call{
    func findLast(byNumber number: String?) -> Call?{
        guard let number = number else {
            return nil
        }
        let clearNumber = number.onlyDigits()
        var target: Call? = nil
        
        for call in self{
            if call.abonent == clearNumber{
                target = call
                break
            }
        }
        return target
    }
}
