//
//  SpamViewController.swift
//  GuessWho
//
//  Created by Anton Grachev on 14/11/2016.
//  Copyright © 2016 Anton Grachev. All rights reserved.
//

import UIKit
import CoreData
import SharedStorage
import CallKit

class SpamViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var selectedPhoneNumber: PhoneNumber?
    fileprivate var fetchedResultsController: NSFetchedResultsController<PhoneNumberEntity>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let fetchRequest = PhoneNumberEntity.fetchRequest() as NSFetchRequest<PhoneNumberEntity>
        let sortDescriptor = NSSortDescriptor(key: "phoneNumber", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "(contentFlags & %i) > 0", ContentFlags.userGeneratedContent.rawValue)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: SharedStorage.defaultStorage.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            print("Error while fetching data: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UIStoryboardSegue.showPhoneNumberSegueId {
            let infoController = segue.destination as! PhoneInfoViewController
            infoController.selectedPhoneNumber = selectedPhoneNumber
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func unwinedSegueCancel(_ segue: UIStoryboardSegue) {
        selectedPhoneNumber = nil
    }
    
    @IBAction func unwinedSegueSave(_ segue: UIStoryboardSegue) {
        selectedPhoneNumber = nil
        reloadExtensions()
    }
    
    @IBAction func unwinedSegueDelete(_ segue: UIStoryboardSegue) {
        selectedPhoneNumber = nil
        reloadExtensions()
    }
    
    // MARK: - Private methods
    
    private func reloadExtensions() {
        CallKitHandler.reloadSpamExtension()
        CallKitHandler.reloadYellowPagesExtension()
    }
    
    fileprivate func configureCell(_ cell: SpamPhoneNumberCell, at indexPath: IndexPath) {
        let phoneNumber = fetchedResultsController.object(at: indexPath)
        
        cell.phoneLabel.text = String(phoneNumber.phoneNumber)
        cell.descriptionLabel.text = phoneNumber.label
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension SpamViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! SpamPhoneNumberCell
            configureCell(cell, at: indexPath!)
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - UITableViewDataSource

extension SpamViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contoller = fetchedResultsController {
            return contoller.sections?[section].numberOfObjects ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpamPhoneNumberCell.identifier, for: indexPath) as! SpamPhoneNumberCell
        
        configureCell(cell, at: indexPath)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SpamViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPhoneNumber = fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: UIStoryboardSegue.showPhoneNumberSegueId, sender: self)
    }
}
