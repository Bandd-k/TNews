//
//  NewsListViewController.swift
//  TNews
//
//  Created by Denis Karpenko on 01.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit

class NewsListViewController: UIViewController {

    @IBOutlet weak var newsTableView: UITableView!

    var downloader: DataDownloader?
    
    var dataProvider: NewsDataProvider?
    override func viewDidLoad() {
        super.viewDidLoad()
        let stack = CoreDataStack()
        dataProvider = NewsDataProvider(tableView: newsTableView,coreDataStack: stack)
        downloader = DataDownloader(coreDataStack: stack)
        newsTableView.dataSource = self
        newsTableView.delegate = self
        do {
            try dataProvider?.fetchedResultsController.performFetch()
        } catch {
            print("Error fetching: \(error)")
        }
        downloader?.downloadMore()
        // Do any additional setup after loading the view, typically from a nib.
    }

}

// MARK: - UITableViewDataSource
extension NewsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let frc = dataProvider?.fetchedResultsController, let sectionsCount =
            frc.sections?.count else {
                return 0
        }
        return sectionsCount
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let frc = dataProvider?.fetchedResultsController, let sections = frc.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell")!
        if let news = dataProvider?.fetchedResultsController.object(at: indexPath) {
            cell.textLabel?.text = news.text
        }
        return cell
        
    }

}

// MARK: - UITableViewDataSource
extension NewsListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let frc = dataProvider?.fetchedResultsController, let sections = frc.sections else {
            return
        }
        if sections[0].numberOfObjects == indexPath.row+5 { // make isDownloading flag
            downloader?.downloadMore()
        }
    }
}

