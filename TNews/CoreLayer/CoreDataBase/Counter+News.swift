//
//  Counter+News.swift
//  TNews
//
//  Created by Denis Karpenko on 07.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation
import CoreData

extension Counter {
    static func insertCounter(with id: String,in context: NSManagedObjectContext) -> Counter? {
        if let counter = NSEntityDescription.insertNewObject(forEntityName: "Counter", into: context) as? Counter {
            counter.id = id
            return counter
        }
        return nil
    }
    
    static func findOrInsertCounter(with id: String,in context: NSManagedObjectContext) -> Counter? {
        if let counter = findCounter(with: id, in: context){
            return counter
        }
        else{
            return insertCounter(with: id, in: context)
        }
    }
    
    static func findCounter(with id: String, in context: NSManagedObjectContext) -> Counter? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print ("Model is not available in context")
            assert(false)
            return nil
        }
        var counter : Counter?
        guard let fetchRequest = Counter.fetchRequestCounter(with: id,model: model) else {
            return nil
        }
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple counters with same id found!")
            if let foundCounters = results.first {
                counter = foundCounters
            }
        } catch {
            print ("Failed to fetch counters: \(error)")
        }
        return counter
    }
    
    static func fetchRequestCounter(with id:String, model: NSManagedObjectModel) -> NSFetchRequest<Counter>? {
        let templateName = "CounterId"
        
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["id" : id]) as? NSFetchRequest<Counter> else{
            assert(false,"No template with name \(templateName)")
            return nil
        }
        return fetchRequest
    }
}
