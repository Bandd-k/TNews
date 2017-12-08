//
//  ContentDownloaderService.swift
//  TNews
//
//  Created by Denis Karpenko on 04.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit

protocol IContentDownloaderService{
    func downloadContent(id: String,completionHandler: @escaping (String?, String?) -> Void)
}

class ContentDownloaderService: IContentDownloaderService {
    
    let requestSender: IRequestSender
    
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    func downloadContent(id:String, completionHandler: @escaping (String?, String?) -> Void) {
        let requestConfig: RequestConfig<String> = RequestsConfigFactory.contentConfig(id: id)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestSender.send(config: requestConfig) { (result: Result<String>) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            switch result {
            case .Success(let content):
                completionHandler(content, nil)
            case .Fail(let error):
                completionHandler(nil, error)
            }
        }
        
    }
}
