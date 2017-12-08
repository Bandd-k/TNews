//
//  StorageManager.swift
//  TNews
//
//  Created by Denis Karpenko on 05.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation
import CoreData

protocol IStorageManager {
    func save(elements: [NewsApiModel], completionHandler: @escaping (String?) -> Void)
    func incrementCounter(id: String,completionHandler: @escaping (String?) -> Void)
    func add(content: String,id: String, completionHandler: @escaping (String?) -> Void)
    func refresh(elements:[NewsApiModel],completionHandler: @escaping (String?) -> Void)
}

class StorageManager: IStorageManager {
    let coreDataStack:CoreDataStack
    init(with coreStack:CoreDataStack){
        coreDataStack = coreStack
    }
    func save(elements:[NewsApiModel],completionHandler: @escaping (String?) -> Void){
        guard let context = coreDataStack.saveContext else {
            completionHandler("no saveContext")
            return
        }
        for element in elements {
            News.findOrInsertNews(with: element.id, name: element.name, text: element.text,date: element.date, in: context)
        }
        coreDataStack.performSave(context: context, completionHandler: completionHandler)
    }
    
    func refresh(elements:[NewsApiModel],completionHandler: @escaping (String?) -> Void){
        guard let context = coreDataStack.saveContext else {
            completionHandler("no saveContext")
            return
        }
        let fetchRequest = NSFetchRequest<News>(entityName: "News")
        let sortByTimestamp = NSSortDescriptor(key: "date",ascending: false)
        fetchRequest.sortDescriptors = [sortByTimestamp]
        for element in elements {
            News.insertOrUpdate(with: element.id, name: element.name, text: element.text,date: element.date, in: context)
        }
        
        do {
            let result = try context.fetch(fetchRequest)
            let batch = 20
            for object in result[batch...] {
                context.delete(object)
            }
        } catch {
            completionHandler("Error fetching: \(error)")
        }
        coreDataStack.performSave(context: context, completionHandler: completionHandler)
    }
    
    func add(content: String, id: String,completionHandler: @escaping (String?) -> Void) {
        guard let context = coreDataStack.saveContext else {
            completionHandler("no saveContext")
            return
        }
        guard let news = News.findNews(with: id, in: context) else {
            completionHandler("no such element in base")
            return
        }
        news.content = content
        coreDataStack.performSave(context: context, completionHandler: completionHandler)
    }
    
    func incrementCounter(id: String, completionHandler: @escaping (String?) -> Void) {
        guard let context = coreDataStack.saveContext else {
            completionHandler("no saveContext")
            return
        }
        guard let news = News.findNews(with: id, in: context) else {
            completionHandler("no such element in base")
            return
        }
        news.count?.counter += 1
        news.counter += 1
        coreDataStack.performSave(context: context, completionHandler: completionHandler)
    }
    
}


