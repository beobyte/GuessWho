//
//  PhoneNumber.swift
//  GuessWho
//
//  Created by Anton Grachev on 15/11/2016.
//  Copyright © 2016 Anton Grachev. All rights reserved.
//

import Foundation

public protocol PhoneNumber {
    var contentFlags: Int16 { get }
    var isSpam: Bool { get set }
    var label: String? { get }
    var phoneNumber: Int64 { get }
}

public enum ContentFlags: Int16 {
    case internalContent = 0b00000001
    case userGeneratedContent = 0b00000010
}
