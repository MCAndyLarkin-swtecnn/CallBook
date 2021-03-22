//
//  MessageStorage.swift
//  callBook
//
//  Created by user on 21.03.2021.
//

import UIKit

struct MessageStorage {
    var history: [(sender: Sender, text: String)]?
    var draft: String
}
enum Sender {
    case me
    case forMe
}
