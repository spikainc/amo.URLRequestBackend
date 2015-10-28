//
//  URLRequestBackend.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/14.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import Either
import Promise

public typealias Request = (request: NSMutableURLRequest, context: AnyObject?)
public typealias Result = (request: Request, response: NSURLResponse!, data: AnyObject?)
public typealias RequestHandler = (Request -> Promise<Result>)

private let defaultOperationQueue = NSOperationQueue()

public class Manager {
    private let operationQueue: NSOperationQueue
    private let requestHandler: Manager -> RequestHandler
    private var plugins = [PluginProtocol]()
    
    public class var sharedInstance: Manager {
        struct Shared {
            static let instance = Manager()
        }
        return Shared.instance
    }
    
    public init(requestHandler: (Manager -> RequestHandler) = HTTPRequestHandler, operationQueue: NSOperationQueue = defaultOperationQueue) {
        self.requestHandler = requestHandler
        self.operationQueue = operationQueue
    }
    
    public func addPlugin(plugin: PluginProtocol) {
        self.plugins.append(plugin)
    }
    
    public func request(request: NSURLRequest, context: AnyObject? = nil) -> Promise<Result> {
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        var requestPromise = Promise<Request>.resolve((mutableRequest, context))
        for plugin in self.plugins {
            if let intercept = plugin.requestInterceptor() {
                requestPromise = requestPromise.then(intercept)
            }
            if let intercept = plugin.requestErrorInterceptor() {
                requestPromise = requestPromise.fail(intercept)
            }
        }
        
        var resultPromise = requestPromise.then(self.requestHandler(self))
        
        for plugin in self.plugins.reverse() {
            if let intercept = plugin.resultInterceptor() {
                resultPromise = resultPromise.then(intercept)
            }
            
            if let intercept = plugin.resultErrorInterceptor() {
                resultPromise = resultPromise.fail(intercept)
            }
        }
        
        return resultPromise
    }
}

public func HTTPRequestHandler(manager: Manager) -> RequestHandler {
    return { (request: Request) -> Promise<Result> in
        return Promise<Result>({ (deferred) -> () in
            NSURLConnection.sendAsynchronousRequest(request.request, queue: manager.operationQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    deferred.resolve((request, response, data))
                } else {
                    deferred.reject(error)
                }
            })
        })
    }
}
