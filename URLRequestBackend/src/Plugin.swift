//
//  Plugin.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/15.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import Either
import Promise

public protocol PluginProtocol {
    func requestInterceptor() -> (Request -> Either<Request, Promise<Request>>)?
    func requestErrorInterceptor() -> (NSError -> Either<Request, Promise<Request>>)?
    func resultInterceptor() -> (Result -> Either<Result, Promise<Result>>)?
    func resultErrorInterceptor() -> (NSError -> Either<Result, Promise<Result>>)?
}

public struct Plugin {
    public class Base: PluginProtocol {
        public init() {}
        public func requestInterceptor() -> (Request -> Either<Request, Promise<Request>>)? {
            return nil
        }
        
        public func requestErrorInterceptor() -> (NSError -> Either<Request, Promise<Request>>)? {
            return nil
        }
        
        public func resultInterceptor() -> (Result -> Either<Result, Promise<Result>>)? {
            return nil
        }
        
        public func resultErrorInterceptor() -> (NSError -> Either<Result, Promise<Result>>)? {
            return nil
        }
    }
}
