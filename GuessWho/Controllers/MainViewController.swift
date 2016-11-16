//
//  MainViewController.swift
//  GuessWho
//
//  Created by Anton Grachev on 14/11/2016.
//  Copyright © 2016 Anton Grachev. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.bool(forKey: UserDefaults.tutorialPassedKey) {
            performSegue(withIdentifier: UIStoryboardSegue.tutorialSegueId, sender: self)
        }
    }
    
    // MARK: - IBActions

    @IBAction func unwinedSegueDone(_ segue: UIStoryboardSegue) {
        UserDefaults.standard.set(true, forKey: UserDefaults.tutorialPassedKey)
    }
}
