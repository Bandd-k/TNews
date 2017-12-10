//
//  News+CoreData.swift
//  TNews
//
//  Created by Denis Karpenko on 02.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation
import CoreData

extension News {
    static func insertNews(with id: String,name: String,text: String,date: Date,in context: NSManagedObjectContext) -> News? {
        if let news = NSEntityDescription.insertNewObject(forEntityName: "News", into: context) as? News {
            news.id = id
            news.text = text
            news.name = name
            news.date = date
            news.count = Counter.findOrInsertCounter(with: id, in: context)
            if let cnt = news.count?.counter {
                news.counter = cnt
            }
            return news
        }
        return nil
    }
    static func findOrInsertNews(with id: String,name: String,text: String,date: Date,in context: NSManagedObjectContext) -> News? {
        if let news = findNews(with: id, in: context){
            return news
        }
        else{
            return insertNews(with: id, name: name, text: text, date: date, in: context)
        }
    }
    
    static func insertOrUpdate(with id: String,name: String,text: String,date: Date,in context: NSManagedObjectContext) {
        if let news = findNews(with: id, in: context){
            news.name = name
            news.text = text
            news.date = date
        }
        else{
            _ = insertNews(with: id, name: name, text: text, date: date, in: context)
        }
    }
    

    static func findNews(with id: String, in context: NSManagedObjectContext) -> News? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print ("Model is not available in context")
            assert(false)
            return nil
        }
        var news : News?
        guard let fetchRequest = News.fetchRequestNews(with: id,model: model) else {
            return nil
        }
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple news with same id found!")
            if let foundNews = results.first{
                news = foundNews
            }
        } catch {
            print ("Failed to fetch news: \(error)")
        }
        return news
    }
    
    static func fetchRequestNews(with id:String, model: NSManagedObjectModel) -> NSFetchRequest<News>? {
        let templateName = "NewsId"
        
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["id" : id]) as? NSFetchRequest<News> else{
            assert(false,"No template with name \(templateName)")
            return nil
        }
        return fetchRequest
    }
    
}
