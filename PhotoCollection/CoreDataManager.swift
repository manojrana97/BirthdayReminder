//
//
// CoreDataManager.swift
// GroceryList
//
// Oragnizstion: zapbuild
// Created By: zapbuild on 14/06/19
// Swift Version: 5.0
//Copyright © 2019 zapbuild. All rights reserved.
//


import Foundation
import CoreData
import UIKit
// MARK: - PersistentStoreType

/// An enumeration of the three string constants that are used for specifying the persistent store type (NSSQLiteStoreType, NSBinaryStoreType, NSInMemoryStoreType).
public enum PersistentStoreType {
    
    /// Represents the value for NSSQLiteStoreType.
    case sqLite
    
    /// Represents the value for NSBinaryStoreType.
    case binary
    
    /// Represents the value for NSInMemoryStoreType.
    case inMemory
    
    /// Value of the Core Data string constants corresponding to each case.
    var stringValue: String {
        switch self {
        case .sqLite:
            return NSSQLiteStoreType
        case .binary:
            return NSBinaryStoreType
        case .inMemory:
            return NSInMemoryStoreType
        }
    }
}

// MARK: - Logger

/**
 *  Defines requirements for a logger that DataManager can use to log errors.
 */
public protocol DataManagerErrorLogger {
    
    /**
     This method is called when DataManager catches a thrown error internally. Custom loggers may have this method print to the console or write to a file.
     
     - parameter error:    The error that was thrown.
     - parameter file:     The file from which the error logging method was called from.
     - parameter function: The function from which the error logging method was called from.
     - parameter line:     The line number in the file from which the error logging method was called from.
     */
    func log(error: NSError, file: StaticString, function: StaticString, line: UInt)
}

// MARK: - DefaultLogger

private class DefaultLogger: DataManagerErrorLogger {
    
    func log(error: NSError, file: StaticString, function: StaticString, line: UInt) {
       
    }
}

// MARK: - _Constants

private struct _Constants {
    
    static fileprivate let mustCallSetupMethodErrorMessage = "DataManager must be set up using setUp(withDataModelName:bundle:persistentStoreType:) before it can be used."
}

// MARK: - DataManager

/**
 Responsible for setting up the Core Data stack. Also provides some convenience methods for fetching, deleting, and saving.
 */
public final class DataManager {
    
    // MARK: Properties
    
    private static var dataModelName: String?
    private static var dataModelBundle: Bundle?
    private static var persistentStoreName: String?
    private static var persistentStoreType = PersistentStoreType.sqLite
    
    /// The logger to use for logging errors caught internally. A default logger is used if a custom one isn't provided. Assigning nil to this property prevents DataManager from emitting any logs to the console.
    public static var errorLogger: DataManagerErrorLogger? = DefaultLogger()
    
    /// The value to use for `fetchBatchSize` when fetching objects.
    public static var defaultFetchBatchSize = 50
    
    // MARK: Setup
    
    /**
     This method must be called before DataManager can be used. It provides DataManager with the required information for setting up the Core Data stack. Call this in application(_:didFinishLaunchingWithOptions:).
     
     - parameter dataModelName:       The name of the data model schema file.
     - parameter bundle:              The bundle in which the data model schema file resides.
     - parameter persistentStoreName: The name of the persistent store.
     - parameter persistentStoreType: The persistent store type. Defaults to SQLite.
     */
    public static func setUp(withDataModelName dataModelName: String, bundle: Bundle, persistentStoreName: String, persistentStoreType: PersistentStoreType = .sqLite) {
        
        DataManager.dataModelName = dataModelName
        DataManager.dataModelBundle = bundle
        DataManager.persistentStoreName = persistentStoreName
        DataManager.persistentStoreType = persistentStoreType
    }
    
    // MARK: Core Data Stack
    
    private static var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    private static var managedObjectModel: NSManagedObjectModel = {
        
        guard let dataModelName = DataManager.dataModelName else {
            fatalError("Attempting to use nil data model name. \(_Constants.mustCallSetupMethodErrorMessage)")
        }
        
        guard let modelURL = DataManager.dataModelBundle?.url(forResource: DataManager.dataModelName, withExtension: "momd") else {
            fatalError("Failed to locate data model schema file.")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to created managed object model")
        }
        
        return managedObjectModel
    }()
    
    private static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        guard let persistentStoreName = DataManager.persistentStoreName else {
            fatalError("Attempting to use nil persistent store name. \(_Constants.mustCallSetupMethodErrorMessage)")
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: DataManager.managedObjectModel)
        let url = DataManager.applicationDocumentsDirectory.appendingPathComponent("\(persistentStoreName).sqlite")
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        do {
            try coordinator.addPersistentStore(ofType: DataManager.persistentStoreType.stringValue, configurationName: nil, at: url, options: options)
        }
        catch let error as NSError {
            fatalError("Failed to initialize the application's persistent data: \(error.localizedDescription)")
        }
        catch {
            fatalError("Failed to initialize the application's persistent data")
        }
        return coordinator
    }()
    
    static var privateContext: NSManagedObjectContext = {
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = DataManager.persistentStoreCoordinator
        return context
    }()
    
    /// A MainQueueConcurrencyType context whose parent is a PrivateQueueConcurrencyType context. The PrivateQueueConcurrencyType context is the root context.
    public static var mainContext: NSManagedObjectContext = {
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = DataManager.privateContext
        return context
    }()
    
    // MARK: Child Contexts
    
    /**
     Creates a private queue concurrency type context that is the child of the specified parent context.
     
     - parameter parentContext: The context to act as the parent of the returned context.
     
     - returns: A private queue concurrency type context that is the child of the specified parent context.
     */
    public static func createChildContext(withParent parent: NSManagedObjectContext) -> NSManagedObjectContext {
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = parent
        return managedObjectContext
    }
    
    // MARK: Fetching
    
    /**
     This is a convenience method for performing a fetch request. Note: Errors thrown by executeFetchRequest are suppressed and logged in order to make usage less verbose. If detecting thrown errors is needed in your use case, you will need to use Core Data directly.
     
     - parameter entity:          The NSManagedObject subclass to be fetched.
     - parameter predicate:       A predicate to use for the fetch if needed (defaults to nil).
     - parameter sortDescriptors: Sort descriptors to use for the fetch if needed (defaults to nil).
     - parameter context:         The NSManagedObjectContext to perform the fetch with.
     
     - returns: A typed array containing the results. If executeFetchRequest throws an error, an empty array is returned.
     */
    public static func fetchObjects<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext) -> [T] {
        
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchBatchSize = defaultFetchBatchSize
        
        do {
            return try context.fetch(request)
        }
        catch let error as NSError {
            log(error: error)
            return [T]()
        }
    }
    
    /**
     This is a convenience method for performing a fetch request that fetches a single object. Note: Errors thrown by executeFetchRequest are suppressed and logged in order to make usage less verbose. If detecting thrown errors is needed in your use case, you will need to use Core Data directly.
     
     - parameter entity:          The NSManagedObject subclass to be fetched.
     - parameter predicate:       A predicate to use for the fetch if needed (defaults to nil).
     - parameter sortDescriptors: Sort descriptors to use for the fetch if needed (defaults to nil).
     - parameter context:         The NSManagedObjectContext to perform the fetch with.
     
     - returns: A typed result if found. If executeFetchRequest throws an error, nil is returned.
     */
    public static func fetchObject<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext) -> T? {
        
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        }
        catch let error as NSError {
            log(error: error)
            return nil
        }
    }
    
    // MARK: Deleting
    
    /**
     Iterates over the objects and deletes them using the supplied context.
     
     - parameter objects: The objects to delete.
     - parameter context: The context to perform the deletion with.
     */
    public static func delete(_ objects: [NSManagedObject], in context: NSManagedObjectContext) {
        
        for object in objects {
            context.delete(object)
        }
    }
    
    /**
     For each entity in the model, fetches all objects into memory, iterates over each object and deletes them using the main context. Note: Errors thrown by executeFetchRequest are suppressed and logged in order to make usage less verbose. If detecting thrown errors is needed in your use case, you will need to use Core Data directly.
     */
//    public static func deleteAllObjects(isDeleteUser: Bool) {
//
//        for entityName in managedObjectModel.entitiesByName.keys {
//
//            if !isDeleteUser && entityName == Constants.CoreData.Entity.user {
//                continue
//            }
//
//            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
//            request.includesPropertyValues = false
//
//            do {
//                for object in try mainContext.fetch(request) {
//                    mainContext.delete(object)
//                }
//            }
//            catch let error as NSError {
//                log(error: error)
//            }
//        }
//        persist(synchronously: true)
//    }
    
    // MARK: Saving
    
    /**
     Saves changes to the persistent store. This function save changes in Core Data stack those are in cache. Call it after updating Core Data object. Otherwise Core Data stack will provide in appropriate data conflicting with Cache and Persistent data.
     
     - parameter synchronously: Whether the main thread should block while writing to the persistent store or not.
     - parameter completion:    Called after the save on the private context completes. If there is an error, it is called immediately and the error parameter is populated.
     */
    public static func persist(synchronously: Bool, completion: ((NSError?) -> Void)? = nil) {
        
        var mainContextSaveError: NSError?
        
        if mainContext.hasChanges {
            mainContext.performAndWait {
                do {
                    try self.mainContext.save()
                }
                catch var error as NSError {
                    mainContextSaveError = error
                }
            }
        }
        
        guard mainContextSaveError == nil else {
            completion?(mainContextSaveError)
            return
        }
        
        func savePrivateContext() {
            do {
                try privateContext.save()
                completion?(nil)
            }
            catch let error as NSError {
                completion?(error)
            }
        }
        
        if privateContext.hasChanges {
            if synchronously {
                privateContext.performAndWait(savePrivateContext)
            }
            else {
                privateContext.perform(savePrivateContext)
            }
        }
    }
    
    // MARK: Logging
    
    private static func log(error: NSError, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        
        errorLogger?.log(error: error, file: file, function: function, line: line)
    }
    
    //MARK: Create default data
    
//    static func createDefaultData() {
//       //Create Default icon
//       DefaultIcon.createDefaultIcons()
//        
//        //Create default data in core data stack
//        ItemCategory.createDefaultCategory()
//        // Create default lists
//        List.createDefaultLists()
//        
//     
//    }
}
