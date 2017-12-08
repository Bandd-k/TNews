//
//  RequestsConfigFactory.swift
//  TNews
//
//  Created by Denis Karpenko on 04.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation

struct RequestsConfigFactory {
    static func listConfig(from first: Int) -> RequestConfig<[NewsApiModel]> {
        let request = RequestMaker().listRequest(from: first)
        return RequestConfig<[NewsApiModel]>(request:request, parser: ListParser())
    }
    static func contentConfig(id: String) -> RequestConfig<String> {
        let request = RequestMaker().contentRequest(id: id)
        return RequestConfig<String>(request:request, parser: ContentParser())
    }
}
