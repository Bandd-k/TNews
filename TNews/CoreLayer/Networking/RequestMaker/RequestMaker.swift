//
//  RequestMaker.swift
//  TNews
//
//  Created by Denis Karpenko on 04.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation

protocol IRequestMaker {
    func contentRequest(id: String) -> URLRequest?
    func listRequest(from first: Int) -> URLRequest?
}

class RequestMaker: IRequestMaker {
    private let baseUrl: String = "https://api.tinkoff.ru/"
    private let apiVersion = "v1/"
    private let listString = "news?"
    private let contentString = "news_content?"
    private let limit: Int
    
    init(limit: Int = 20) {
        self.limit = limit
    }
    func listRequest(from first: Int) -> URLRequest? {
        let urlString: String = baseUrl + apiVersion + listString + "first=\(first)" + "&" + "last=\(first+limit)"
        if let url = URL(string: urlString) {
            return URLRequest(url: url)
        }
        return nil
    }
    func contentRequest(id: String) -> URLRequest? {
        let urlString: String = baseUrl + apiVersion + contentString + "id=\(id)"
        if let url = URL(string: urlString) {
            return URLRequest(url: url)
        }
        return nil
    }
}
