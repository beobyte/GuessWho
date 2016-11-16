//
//  PhoneInfoViewController.swift
//  GuessWho
//
//  Created by Anton Grachev on 15/11/2016.
//  Copyright © 2016 Anton Grachev. All rights reserved.
//

import UIKit
import SharedStorage

class PhoneInfoViewController: UIViewController {

    var selectedPhoneNumber: PhoneNumber?
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let phoneNumber = selectedPhoneNumber {
            phoneTextField.text = String(phoneNumber.phoneNumber)
            descriptionTextField.text = phoneNumber.label
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UIStoryboardSegue.savePhoneNumberSegueId {
            save()
        }
        else if segue.identifier == UIStoryboardSegue.deletePhoneNumberSegueId {
            delete()
        }
    }
    
    // MARK: - Private methods
    
    private func save() {
        if let text = phoneTextField.text, let phoneNumber = Int64(text) {
            var contentFlags = ContentFlags.userGeneratedContent.rawValue
            if let existingNumber = selectedPhoneNumber, existingNumber.phoneNumber == phoneNumber {
                contentFlags = (existingNumber.contentFlags | contentFlags)
            }
            
            SharedStorage.defaultStorage.add(phoneNumber: phoneNumber,
                                             label: descriptionTextField.text ?? "",
                                             isSpam: false,
                                             contentFlags: contentFlags)
        }
    }
    
    private func delete() {
        if let text = phoneTextField.text, let phoneNumber = Int64(text) {
            SharedStorage.defaultStorage.remove(phoneNumber: phoneNumber)
        }
    }
}
