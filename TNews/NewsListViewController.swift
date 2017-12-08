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
    var mainModel: IMainModel!
    let downloadOffset = 5
    override func viewDidLoad() {
        super.viewDidLoad()
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
        refreshControl.attributedTitle = NSAttributedString(string: "Looking for something new", attributes: nil)
    }
    
    @objc private func refreshData(){
        mainModel.refresh()
    }

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
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
        return 1
//        guard let frc = dataProvider?.fetchedResultsController, let sectionsCount =
//            frc.sections?.count else {
//                return 0
//        }
//        return sectionsCount
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(mainModel.numberOfElements)
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
        if let news = mainModel?.object(at: indexPath) {
            cell.configure(from: news)
        }
        return cell
        
    }

}

// MARK: - UITableViewDelegate
extension NewsListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if mainModel.numberOfElements == indexPath.row + downloadOffset {
            mainModel.loadMore()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if let news = mainModel?.object(at: indexPath) {
//            if (news.content == nil) {
//                mainModel?.loadContent(id: news.id!)
//            }
//        }
    }
}

