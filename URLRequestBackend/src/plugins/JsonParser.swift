//
//  JsonParser.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/15.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import Either
import Promise

extension Plugin {
    public class JsonParser: Base {
        let option: NSJSONReadingOptions
        public init(option: NSJSONReadingOptions = .AllowFragments) {
            self.option = option
        }
        
        public override func resultInterceptor() -> (Result -> Either<Result, Promise<Result>>)? {
            return self.interceptResult
        }
        
        public func interceptResult(result: Result) -> Either<Result, Promise<Result>> {
            if let data = result.data as? NSData {
                let ret: (json: AnyObject?, error: NSError?) = self.parse(data)
                if let e = ret.error {
                    return Either<Result, Promise<Result>>.bind(Promise<Result>.reject(e))
                }
                return Either<Result, Promise<Result>>.bind((result.request, result.response, ret.json))
            }
            return Either<Result, Promise<Result>>.bind(result)
        }
        
        public func parse(data: NSData!) -> (AnyObject?, NSError?) {
            if data == nil || data.length == 0 {
                return (nil, nil)
            }
            
            var error: NSError?
            let json: AnyObject? = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) // TODO: throwに対してcatch対応
            
            return (json, nil)
        }
    }
}
