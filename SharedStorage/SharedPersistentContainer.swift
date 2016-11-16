//
//  SharedPersistentContainer.swift
//  GuessWho
//
//  Created by Anton Grachev on 14/11/2016.
//  Copyright © 2016 Anton Grachev. All rights reserved.
//

import CoreData

struct CoreDataServiceConsts {
    static let applicationGroupIdentifier = "group.com.agrachev.guesswho.container"
}

final class SharedPersistentContainer: NSPersistentContainer {
    internal override class func defaultDirectoryURL() -> URL {
        var url = super.defaultDirectoryURL()
        if let newURL =
            FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: CoreDataServiceConsts.applicationGroupIdentifier) {
            url = newURL
        }
        return url
    }
}
