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
    func loadContent(id:String,completion: @escaping ((String?) -> Void))
    func incrementCount(id:String)
}

protocol IMainModelDelegate: class {
    func show(error message: String)
    func stopRefresh()
}

class MainModel: NSObject {
    internal weak var delegate: IMainModelDelegate?
    private let fetchedResultsController: NSFetchedResultsController<News>
    private unowned let tableView: UITableView
    private let coreDataStack = CoreDataStack()
    private let storageManager: IStorageManager
    private let listService: ListDownloaderService
    private let contentService: ContentDownloaderService
    private var isDonwloading = false
    
    
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
    
    func loadContent(id:String,completion:@escaping ((String?) -> Void)){
        contentService.downloadContent(id: id) {[weak self] (content, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.delegate?.show(error: error)
                completion(nil)
                return
            }
            if let content = content {
                completion(content)
                strongSelf.storageManager.add(content: content,id: id) {[weak self] (error) in
                    guard let strongSelf = self else { return }
                    if let error = error {
                        strongSelf.delegate?.show(error: error)
                        completion(nil)
                        return
                    }
                }
            }
        }
    }
    
    func refresh() { // delete old news and fetch new
        if (isDonwloading==false){
            isDonwloading = true
            let startPoint = 0
            listService.downloadList(from: startPoint) {[weak self] (newsList, error) in
                guard let strongSelf = self else { return }
                if let error = error {
                    strongSelf.isDonwloading = false
                    strongSelf.delegate?.show(error: error)
                    return
                }
                strongSelf.delegate?.stopRefresh()
                if let newsList = newsList {
                    strongSelf.storageManager.refresh(elements: newsList) {[weak self] (error) in
                        guard let strongSelf = self else { return }
                        strongSelf.isDonwloading = false
                        if let error = error {
                            strongSelf.delegate?.show(error: error)
                            return
                        }
                        else{
                            strongSelf.delegate?.stopRefresh()
                        }
                    }
                }
            }
        }
        
    }
    
    func loadMore() {
        if (isDonwloading==false){
            isDonwloading = true
            listService.downloadList(from: numberOfElements) {[weak self] (newsList, error) in
                guard let strongSelf = self else { return }
                if let error = error {
                    strongSelf.isDonwloading = false
                    strongSelf.delegate?.show(error: error)
                    return
                }
                
                if let newsList = newsList {
                    strongSelf.storageManager.save(elements: newsList) {[weak self] (error) in
                        guard let strongSelf = self else { return }
                        strongSelf.isDonwloading = false
                        if let error = error {
                            strongSelf.delegate?.show(error: error)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func incrementCount(id: String) {
        self.storageManager.incrementCounter(id: id) {[weak self] (error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.delegate?.show(error: error)
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
