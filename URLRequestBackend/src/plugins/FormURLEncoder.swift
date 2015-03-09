//
//  FormURLEncoder.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/15.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import Either
import Promise

extension Plugin {
    public class FormURLEncoder: Base {
        let parametersKey: String
        
        public init(parametersKey: String = "parameters") {
            self.parametersKey = parametersKey
        }
        
        public override func requestInterceptor() -> (Request -> Either<Request, Promise<Request>>)? {
            return Either<Request, Promise<Request>>.bindFunc(interceptRequest)
        }
        
        public func interceptRequest(request: Request) -> Request {
            request.request.HTTPMethod = "POST"
            
            let parameters = request.context?[parametersKey]? as? [String: AnyObject]
            if parameters == nil {
                return request
            }
            
            let urlComponents: NSURLComponents! = NSURLComponents(URL: request.request.URL!, resolvingAgainstBaseURL: false)
            if urlComponents == nil {
                return request
            }
            
            
            if request.request.valueForHTTPHeaderField("Content-Type") == nil {
               request.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
            
            let query = Util.escapeParameters(parameters!)
            if let data = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                request.request.HTTPBody = data
                request.request.setValue("\(data.length)", forHTTPHeaderField: "Content-Length")
            }
            
            return request
        }
    }
}
