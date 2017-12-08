//
//  ListParser.swift
//  TNews
//
//  Created by Denis Karpenko on 04.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation


struct NewsApiModel {
    let id: String
    let name: String
    let text: String
    let date: Date
}

class ListParser: Parser<[NewsApiModel]>{
    override func parse(data: Data)->[NewsApiModel]?{
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



