//
//  URLRequestBackend.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/14.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import Promise

public typealias Request = (request: NSMutableURLRequest, context: AnyObject?)
public typealias Result = (request: Request, response: NSURLResponse, data: AnyObject?)
public typealias RequestHandler = (request: Request) -> Promise<Result>

public class Manager {
    private let requestHandler: RequestHandler
    private var plugins = [PluginProtocol]()
    
    public class var sharedInstance: Manager {
        struct Shared {
            static let instance = Manager()
        }
        return Shared.instance
    }
    
    public init(requestHandler: RequestHandler = HTTPRequestHandler) {
        self.requestHandler = requestHandler
    }
    
    public func addPlugin(plugin: PluginProtocol) {
        self.plugins.append(plugin)
    }
    
    public func request(request: NSURLRequest, context: AnyObject? = nil) -> Promise<Result> {
        var mutableRequest = request.mutableCopy() as NSMutableURLRequest
        var requestPromise = Promise<Request>.resolve((mutableRequest, context))
        for plugin in self.plugins {
            if let intercept = plugin.requestInterceptor() {
                requestPromise = requestPromise.then(intercept)
            }
            if let intercept = plugin.requestErrorInterceptor() {
                requestPromise = requestPromise.catch(intercept)
            }
        }
        
        var responsePromise = requestPromise.then(self.requestHandler)
        
        for plugin in reverse(self.plugins) {
            if let intercept = plugin.resultInterceptor() {
                responsePromise = responsePromise.then(intercept)
            }
            
            if let intercept = plugin.resultErrorInterceptor() {
                responsePromise = responsePromise.catch(intercept)
            }
        }
        
        return responsePromise
    }
}

public func HTTPRequestHandler(request: Request) -> Promise<Result> {
    return Promise<Result>({ (deferred) -> () in
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request.request, queue: queue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                deferred.resolve((request, response, data))
            } else {
                deferred.reject(error)
            }
        })
    })
}

public protocol PluginProtocol {
    func requestInterceptor() -> (Request -> Promise<Request>)?
    func requestErrorInterceptor() -> (NSError -> Promise<Request>)?
    func resultInterceptor() -> (Result -> Promise<Result>)?
    func resultErrorInterceptor() -> (NSError -> Promise<Result>)?
}

public struct Plugin {
    public class Base: PluginProtocol {
        public init() {}
        public func requestInterceptor() -> (Request -> Promise<Request>)? {
            return nil
        }
        
        public func requestErrorInterceptor() -> (NSError -> Promise<Request>)? {
            return nil
        }
        
        public func resultInterceptor() -> (Result -> Promise<Result>)? {
            return nil
        }

        public func resultErrorInterceptor() -> (NSError -> Promise<Result>)? {
            return nil
        }
    }
}

extension Plugin {
    public class JsonParser: Base {
        let option: NSJSONReadingOptions
        public init(option: NSJSONReadingOptions = .AllowFragments) {
            self.option = option
        }
        
        public override func resultInterceptor() -> (Result -> Promise<Result>)? {
            return self._interceptResult
        }
        
        private func _interceptResult(result: Result) -> Promise<Result> {
            if let data = result.data? as? NSData {
                let (json: AnyObject?, error) = self.parse(data)
                if let e = error {
                    return Promise<Result>.reject(e)
                }
                return Promise<Result>.resolve((result.request, result.response, json))
            }
            return Promise<Result>.resolve(result)
        }
        
        public func parse(data: NSData!) -> (AnyObject?, NSError?) {
            if data == nil || data.length == 0 {
                return (nil, nil)
            }
            
            var error: NSError?
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &error)
            
            return (json, error)
        }
    }
}

