//
//  QueryEncoder.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/15.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import Either
import Promise

extension Plugin {
    public class QueryEncoder: Base {
        public override func requestInterceptor() -> (Request -> Either<Request, Promise<Request>>)? {
            return Either<Request, Promise<Request>>.bindFunc(interceptRequest)
        }
        
        public func interceptRequest(request: Request) -> Request {
            let parameters = request.context?["paramerets"]? as? [String: AnyObject]
            if parameters == nil {
                return request
            }
            
            let urlComponents: NSURLComponents! = NSURLComponents(URL: request.request.URL!, resolvingAgainstBaseURL: false)
            if urlComponents == nil {
                return request
            }
            
            let query = Util.escapeParameters(parameters!)
            urlComponents.percentEncodedQuery = (urlComponents.percentEncodedQuery != nil ? urlComponents.percentEncodedQuery! + "&" : "") + query
            request.request.URL = urlComponents.URL
            
            return request
        }
    }
}
