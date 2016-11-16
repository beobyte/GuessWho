//
//  SharedStorage.swift
//  GuessWho
//
//  Created by Anton Grachev on 14/11/2016.
//  Copyright © 2016 Anton Grachev. All rights reserved.
//

import Foundation
import CoreData

final public class SharedStorage {
    
    public static let defaultStorage = SharedStorage()
    
    public var errorHandler: (Error) -> Void = { _ in }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = SharedPersistentContainer(name: "SharedStorage", managedObjectModel: self.managedObjectModel)
        container.loadPersistentStores(completionHandler: { [weak self](storeDescription, error) in
            if let error = error {
                NSLog("CoreData error \(error), \(error._userInfo)")
                self?.errorHandler(error)
            }
        })
        
        return container
    }()
    
    public lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle(for: type(of: self)).url(forResource: "SharedStorageModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // MARK: - Public methods
    
    public func add(phoneNumber: Int64, label: String, isSpam: Bool, contentFlags: Int16) {
        let fetchRequest = PhoneNumberEntity.fetchRequest() as NSFetchRequest<PhoneNumberEntity>
        fetchRequest.predicate = NSPredicate(format: "phoneNumber = %lld", phoneNumber)
        
        do {
            if let existingNumber = try viewContext.fetch(fetchRequest).first {
                existingNumber.label = label
                existingNumber.contentFlags = contentFlags
            }
            else {
                let entity = NSEntityDescription.insertNewObject(forEntityName: "PhoneNumberEntity", into: viewContext) as! PhoneNumberEntity
                entity.phoneNumber = phoneNumber
                entity.label = label
                entity.isSpam = isSpam
                entity.contentFlags = contentFlags
            }
            
            try viewContext.save()
        }
        catch {
            print("Error while adding phone number: \(error)")
        }
    }
    
    public func remove(phoneNumber: Int64) {
        let fetchRequest = PhoneNumberEntity.fetchRequest() as NSFetchRequest<PhoneNumberEntity>
        fetchRequest.predicate = NSPredicate(format: "phoneNumber = %lld", phoneNumber)
        
        do {
            if let existingNumber = try viewContext.fetch(fetchRequest).first {
                if existingNumber.contentFlags & ContentFlags.internalContent.rawValue > 0 {
                    existingNumber.contentFlags = ContentFlags.internalContent.rawValue
                }
                else {
                    viewContext.delete(existingNumber)
                }
            }
            try viewContext.save()
        }
        catch {
            print("Error while removing phone number: \(error)")
        }
    }
    
    public func allSpamPhoneNumbers() -> [PhoneNumber]? {
        let predicate = NSPredicate(format: "isSpam = %@", NSNumber(booleanLiteral: true))
        return phoneNumbers(with: predicate)
    }
    
    public func allYellowPagesPhoneNumbers() -> [PhoneNumber]? {
        let predicate = NSPredicate(format: "isSpam = %@", NSNumber(booleanLiteral: false))
        return phoneNumbers(with: predicate)
    }
    
    public func markUserGeneratedPhoneNumbers(asSpam: Bool) {
        if let phoneNumbers = allUserGeneratedPhoneNumbers() {
            for phoneNumber in phoneNumbers {
                phoneNumber.isSpam = asSpam
            }
            
            do {
                try viewContext.save()
            }
            catch {
                print("Error while setting isSpam flag for user phone numbers: \(error)")
            }
        }
    }
    
    // MARK: - Private methods
    
    private func allUserGeneratedPhoneNumbers() -> [PhoneNumberEntity]? {
        let predicate = NSPredicate(format: "(contentFlags & %i) > 0", ContentFlags.userGeneratedContent.rawValue)
        return phoneNumbers(with: predicate) as? [PhoneNumberEntity]
    }
    
    private func phoneNumbers(with predicate: NSPredicate) -> [PhoneNumber]? {
        let fetchRequest = PhoneNumberEntity.fetchRequest() as NSFetchRequest<PhoneNumberEntity>
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "phoneNumber", ascending: true)
        fetchRequest.sortDescriptors = [ sortDescriptor ]
        
        let results = try? viewContext.fetch(fetchRequest)
        return results
    }
}
