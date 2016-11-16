//
//  PhoneNumberEntity+CoreDataProperties.swift
//  GuessWho
//
//  Created by Anton Grachev on 15/11/2016.
//  Copyright © 2016 Anton Grachev. All rights reserved.
//

import Foundation
import CoreData


extension PhoneNumberEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhoneNumberEntity> {
        return NSFetchRequest<PhoneNumberEntity>(entityName: "PhoneNumberEntity");
    }

    @NSManaged public var contentFlags: Int16
    @NSManaged public var isSpam: Bool
    @NSManaged public var label: String?
    @NSManaged public var phoneNumber: Int64

}

extension PhoneNumberEntity: PhoneNumber {}
