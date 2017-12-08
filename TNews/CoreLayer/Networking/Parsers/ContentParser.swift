//
//  ContentParser.swift
//  TNews
//
//  Created by Denis Karpenko on 04.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation

class ContentParser: Parser<String> {
    override func parse(data: Data) -> String?{
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                return nil
            }
            
            guard let object = json["payload"] as? [String : Any] else { // ERROR MESSAGE HANDLE
                return nil
            }
            guard let content = object["content"] as? String else {
                return nil
            }
            return content
            
        } catch  {
            print("error trying to convert data to JSON")
            return nil
        }
    }
}
