//
//  NewsDataProvider.swift
//  TNews
//
//  Created by Denis Karpenko on 02.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class NewsDataProvider:NSObject {
    let fetchedResultsController: NSFetchedResultsController<News>
    let tableView: UITableView
    init(tableView: UITableView,coreDataStack: CoreDataStack) {
        self.tableView = tableView
        let context = coreDataStack.mainContext
        let fetchRequest = NSFetchRequest<News>(entityName: "News")
        let sortByTimestamp = NSSortDescriptor(key: "date",ascending: false)
        fetchRequest.sortDescriptors = [sortByTimestamp]
        fetchedResultsController = NSFetchedResultsController<News>(fetchRequest:
            fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil,
                          cacheName: nil)
        
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching: \(error)")
        }
        
    }
}

extension NewsDataProvider: NSFetchedResultsControllerDelegate{
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange  anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
