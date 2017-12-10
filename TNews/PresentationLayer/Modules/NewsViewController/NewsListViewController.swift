//
//  NewsListViewController.swift
//  TNews
//
//  Created by Denis Karpenko on 01.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit

class NewsListViewController: UIViewController {
    private var cellHeights: [IndexPath : CGFloat] = [:] // prevents from tableview jumps
    @IBOutlet weak var newsTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var myActivityIndicator: PlaceholderActivity!
    private var mainModel: IMainModel!
    private let downloadOffset = 0 // set position before the end when we start to download a new batch of news
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
    }
    
    func configureController(){
        mainModel = MainModel(tableView: newsTableView)
        newsTableView.dataSource = self
        newsTableView.delegate = self
        mainModel.delegate = self
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            newsTableView.refreshControl = refreshControl
        } else {
            newsTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "обновление", attributes: nil)
    }
    
    @objc private func refreshData(){
        myActivityIndicator.isDownloading = true
        mainModel.refresh()
    }

     // MARK: - Navigation
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //start download before segue and increase counter
        if let cell = sender as? NewsListTableViewCell {
            let contentViewController = segue.destination as! ContentViewController
            if let news = cell.news {
                contentViewController.news = news
                mainModel.incrementCount(id: news.id!)
                mainModel.loadContent(id: news.id!,completion: contentViewController.updateContent)
            }
        }
     }

}

// MARK: - IMainModelDelegate

extension NewsListViewController: IMainModelDelegate {
    func show(error message: String) {
        let alert = UIAlertController(title: "Упс, проблема", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default) { action in
            self.stopRefresh() //small fix because of alert and pull refresh at the same time
            self.myActivityIndicator.isDownloading = false
        })
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func stopRefresh(){
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource
extension NewsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // aplication has one section always!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  mainModel.numberOfElements == 0 {
            newsTableView.separatorStyle = .none
            myActivityIndicator.isHidden = false
        }
        else {
            myActivityIndicator.isHidden = true
            newsTableView.separatorStyle = .singleLine
        }
        return mainModel.numberOfElements
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsListTableViewCell
        cell.configure(from: mainModel.object(at: indexPath))
        return cell
    }

}

// MARK: - UITableViewDelegate
extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
        if mainModel.numberOfElements == indexPath.row + 1 + downloadOffset {
            mainModel.loadMore()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else {
            return CGFloat((mainModel.object(at: indexPath).name?.count)!) //number of characters approximate cell height
        }
        return height
    }
}

