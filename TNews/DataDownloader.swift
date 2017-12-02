//
//  DataDownloader.swift
//  TNews
//
//  Created by Denis Karpenko on 02.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation


class DataDownloader {
    private let baseUrl: String = "https://api.tinkoff.ru/v1/news?"
    let session = URLSession.shared
    let storageManager: StorageManager
    let parser = Parser()
    var page = 0
    init(coreDataStack: CoreDataStack) {
        storageManager = StorageManager(with: coreDataStack)
    }
    
    func downloadMore(){
        downloadList(from: page*20, to: (page+1)*20)
        page+=1
    }
    func downloadList(from first:Int,to last:Int){
        let urlString = baseUrl + "first=\(first)" + "&" + "last=\(last)"
        guard let url = URL(string: urlString) else {
            assertionFailure("url string can't be parsed to URL")
            //completionHandler(Result.Fail())
            return
        }
        let task = session.dataTask(with: url){ (data: Data?, response: URLResponse?, error: Error?) in // SELF CAPTURE
            if let error = error {
                //completionHandler(Result.Fail())
                return
            }
            
            guard let data = data,let parsedModel = self.parser.parse(data: data) else {
                //completionHandler(Result.Fail())
                return
            }
            self.storageManager.addToCoreDataBase(elements: parsedModel)
            print (parsedModel.count)
            
        }
        task.resume()
    }
}


struct NewsApiModel{
    let id:String
    let name:String
    let text:String
    let date: Date
}

class Parser{
    func parse(data: Data)->[NewsApiModel]?{
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                return nil
            }
            
            guard let feed = json["payload"] as? [[String : Any]] else { // ERROR MESSAGE HANDLE
                    return nil
            }
            var news = [NewsApiModel]()
            for entry in feed{
                guard let entryName = entry["name"] as? String,
                let entryId = entry["id"] as? String,
                let entryText = entry["text"] as? String,
                let entryDateDict = (entry["publicationDate"] as? [String : Any]),
                let entryMillisecondsDate = entryDateDict["milliseconds"] as? Double
                    else { continue }
                let entryDate = Date(timeIntervalSince1970: (entryMillisecondsDate / 1000.0))
                news.append(NewsApiModel(id: entryId, name: entryName, text: entryText, date: entryDate))
            }
            return news
        
        } catch  {
            print("error trying to convert data to JSON")
            return nil
        }
    }
}
