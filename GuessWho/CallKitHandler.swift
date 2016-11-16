//
//  CallKitHandler.swift
//  GuessWho
//
//  Created by Anton Grachev on 16/11/2016.
//  Copyright © 2016 Anton Grachev. All rights reserved.
//

import Foundation
import CallKit

enum CallRule: Int {
    case identification
    case block
}

class CallKitHandler {
    static let spamExtensionIdentifier = "com.anton.grachev.GuessWho.Spam"
    static let yellowPagesExtensionIdentifier = "com.anton.grachev.GuessWho.Yellow-Pages"
    
    static func reloadSpamExtension() {
        reloadExtension(withIdentifier: spamExtensionIdentifier)
    }
    
    static func reloadYellowPagesExtension() {
        reloadExtension(withIdentifier: yellowPagesExtensionIdentifier)
    }
    
    private static func reloadExtension(withIdentifier identifier: String) {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: identifier) { status, error in
            guard error == nil else {
                print("Error while gettings status for \(identifier) extension: \(error)")
                return
            }
            
            if status == CXCallDirectoryManager.EnabledStatus.enabled {
                CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: identifier) { error in
                    guard error == nil else {
                        print("Error while reloading status for \(identifier) extension: \(error)")
                        return
                    }
                }
            }
            else {
                print("Extension \(identifier) is unavailable")
            }
        }
    }
}
