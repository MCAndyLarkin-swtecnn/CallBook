//
//  MessageStorage.swift
//  callBook
//
//  Created by user on 21.03.2021.
//

import UIKit

struct MessageStorage {
    let history: [(sender: Sender, text: String)]?
    let draft: String
}
enum Sender {
    case me
    case forMe
}
