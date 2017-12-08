//
//  MainModel.swift
//  TNews
//
//  Created by Denis Karpenko on 03.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol IMainModel {
    weak var delegate: IMainModelDelegate? { get set }
    var numberOfElements: Int { get }
    func loadMore()
    func refresh()
    func object(at index: IndexPath) -> News
    func loadContent(id:String,completion: @escaping ((String) -> Void))
    func incrementCount(id:String)
}

protocol IMainModelDelegate: class {
    func show(error message: String)
    func stopRefresh()
}



class MainModel: NSObject {
    weak var delegate: IMainModelDelegate?
    let fetchedResultsController: NSFetchedResultsController<News>
    let tableView: UITableView
    let coreDataStack = CoreDataStack()
    //var downloadNewMode = true
    let storageManager: IStorageManager
    let listService: ListDownloaderService
    let contentService: ContentDownloaderService
    var isDonwloading = false
    
    
     // MARK: - Initialization
    init(tableView: UITableView) {
        // Services
        let requestSender = RequestSender()
        listService = ListDownloaderService(requestSender: requestSender)
        contentService = ContentDownloaderService(requestSender: requestSender)
        storageManager = StorageManager(with: coreDataStack)
        
        // NSFetchedResultsController
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
            self.delegate?.show(error: "Error fetching: \(error)")
        }
//        if (numberOfElements == 0) {
//            loadMore()
//        }
        refresh()
    }
    
}

 // MARK: - IMainModel

extension MainModel : IMainModel {
    var numberOfElements: Int {
        
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections[0].numberOfObjects// only one section
    }
    
    func object(at index: IndexPath) -> News {
        return  fetchedResultsController.object(at: index)
    }
    
    func loadContent(id:String,completion:@escaping ((String) -> Void)){
        contentService.downloadContent(id: id) { (content, error) in
            if let error = error { // SELF CAPTURING CHECK!!!
                //self.isDonwloading = false
                self.delegate?.show(error: error)
                return
            }
            if let content = content {
                completion(content)
                self.storageManager.add(content: content,id: id) { (error) in
                    //self.isDonwloading = false
                    if let error = error {
                        self.delegate?.show(error: error)
                        return
                    }
                }
            }
        }
    }
    
    func refresh() {
        if (isDonwloading==false){
            isDonwloading = true
            let startPoint = 0
            listService.downloadList(from: startPoint) { (newsList, error) in
                if let error = error { // SELF CAPTURING CHECK!!!
                    self.isDonwloading = false
                    self.delegate?.show(error: error)
                    return
                }
                if let newsList = newsList {
                    self.storageManager.refresh(elements: newsList) { (error) in
                        self.isDonwloading = false
                        self.delegate?.stopRefresh()
                        if let error = error {
                            self.delegate?.show(error: error)
                            return
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    func loadMore() {
        if (isDonwloading==false){
            isDonwloading = true
            listService.downloadList(from: numberOfElements) { (newsList, error) in
                if let error = error { // SELF CAPTURING CHECK!!!
                    self.isDonwloading = false
                    self.delegate?.show(error: error)
                    return
                }
                
                if let newsList = newsList {
                    self.storageManager.save(elements: newsList) { (error) in
                        self.isDonwloading = false
                        if let error = error {
                            self.delegate?.show(error: error)
                            return
                        }
                    }
                }
            }
        }
    }
    
    
    func incrementCount(id: String) {
        self.storageManager.incrementCounter(id: id) { (error) in
            if let error = error {
                self.delegate?.show(error: error)
                return
            }
        }
    }
    
    
    
}




 // MARK: - NSFetchedResultsControllerDelegate
extension MainModel: NSFetchedResultsControllerDelegate {
    
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
