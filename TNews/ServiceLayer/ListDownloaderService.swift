//
//  ListDownloaderService.swift
//  TNews
//
//  Created by Denis Karpenko on 04.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit

protocol IListDownloaderService{
    func downloadList(from first:Int,completionHandler: @escaping ([NewsApiModel]?, String?) -> Void)
}

class ListDownloaderService: IListDownloaderService {
    
    let requestSender: IRequestSender
    
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    
    func downloadList(from first:Int, completionHandler: @escaping ([NewsApiModel]?, String?) -> Void) {
        let requestConfig: RequestConfig<[NewsApiModel]> = RequestsConfigFactory.listConfig(from: first)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestSender.send(config: requestConfig) { (result: Result<[NewsApiModel]>) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            switch result {
            case .Success(let news):
                completionHandler(news, nil)
            case .Fail(let error):
                completionHandler(nil, error)
            }
        }
        
    }
}


