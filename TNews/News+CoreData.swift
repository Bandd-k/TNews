//
//  News+CoreData.swift
//  TNews
//
//  Created by Denis Karpenko on 02.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation
import CoreData

extension News{
    static func insertNews(with id: String,name: String,text: String,date: Date,in context: NSManagedObjectContext) -> News? {
        if let news = NSEntityDescription.insertNewObject(forEntityName: "News", into: context) as? News {
            news.id = id
            news.text = text
            news.name = name
            news.date = date
            news.counter = 0
            return news
        }
        return nil
    }
//    static func findOrInsertNews(with id: String, in context: NSManagedObjectContext) -> News? {
//        return nil
//    }
//
//    static func findNews(with id: String, in context: NSManagedObjectContext) -> News? {
//        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
//            print ("Model is not available in context")
//            assert(false)
//            return nil
//        }
//        var news : News?
//
//
//    }
    
}
