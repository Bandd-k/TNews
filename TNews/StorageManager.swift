//
//  StorageManager.swift
//  TNews
//
//  Created by Denis Karpenko on 02.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation

class StorageManager{
    let coreDataStack:CoreDataStack
    init(with coreStack:CoreDataStack){
        coreDataStack = coreStack
    }
    func addToCoreDataBase(elements:[NewsApiModel]){
        guard let context = coreDataStack.saveContext else{
            print("no saveContext")
            return
        }
        for element in elements {
            News.insertNews(with: element.id, name: element.name, text: element.text,date: element.date, in: context)
        }
        coreDataStack.performSave(context: context, completionHandler: nil)

    }
}
