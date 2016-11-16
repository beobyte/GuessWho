//
//  SettingsViewController.swift
//  GuessWho
//
//  Created by Anton Grachev on 14/11/2016.
//  Copyright © 2016 Anton Grachev. All rights reserved.
//

import UIKit
import SharedStorage

class SettingsViewController: UIViewController {
    
    fileprivate var rowDescriptors: [SettingsTableRows]!
    fileprivate var callRuleIndex: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.callRuleIndexKey)
        }
        get {
            return UserDefaults.standard.integer(forKey: UserDefaults.callRuleIndexKey)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rowDescriptors = createRowDescriptors()
    }
}

// MARK: - Table row descriptors

extension SettingsViewController {
    
    fileprivate enum SettingsTableRows {
        case identififation(String)
        case block(String)
    }
    
    fileprivate func createRowDescriptors() -> [SettingsTableRows] {
        var descriptors = [SettingsTableRows]()
        
        descriptors.append(.identififation(NSLocalizedString("Show identification info", comment: "")))
        descriptors.append(.block(NSLocalizedString("Block all phone calls", comment: "")))
        
        return descriptors
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDescriptors.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Call rules", comment: "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as! SettingCell
        
        let rowDescriptor = rowDescriptors[indexPath.row]
        
        switch rowDescriptor {
        case .block(let title), .identififation(let title):
            cell.settingLabel.text = title
            cell.accessoryType = (callRuleIndex == indexPath.row) ? .checkmark : .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if callRuleIndex != indexPath.row {
            callRuleIndex = indexPath.row
            tableView.reloadData()
            
            SharedStorage.defaultStorage.markUserGeneratedPhoneNumbers(asSpam: indexPath.row == CallRule.block.rawValue)
            CallKitHandler.reloadSpamExtension()
            CallKitHandler.reloadYellowPagesExtension()
        }
    }
}
