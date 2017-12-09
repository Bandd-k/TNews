//
//  NewsListViewController.swift
//  TNews
//
//  Created by Denis Karpenko on 01.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit

class NewsListViewController: UIViewController {
    @IBOutlet weak var placeHolderText: UILabel!
    @IBOutlet weak var placeHolder: UIImageView!
    
    @IBOutlet weak var newsTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private var mainModel: IMainModel!
    private let downloadOffset = 1 // set position before the end when we start download a new batch of news
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
        refreshControl.attributedTitle = NSAttributedString(string: "refreshing", attributes: nil)
    }
    
    @objc private func refreshData(){
        mainModel.refresh()
    }

     // MARK: - Navigation
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
            // perhaps use action.title here
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
            placeHolder.isHidden = false
            placeHolderText.isHidden = false
            newsTableView.separatorStyle = .none
        }
        else {
            placeHolder.isHidden = true
            newsTableView.separatorStyle = .singleLine
            placeHolderText.isHidden = true
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
extension NewsListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if mainModel.numberOfElements <= indexPath.row + downloadOffset {
            mainModel.loadMore()
        }
    }
}

