//
//  URLRequestBackend.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/14.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import Promise

public typealias Response = (request: NSURLRequest, response: NSURLResponse, data: NSData)
public typealias RequestHandler = (request: NSURLRequest) -> Promise<Response>

public protocol Plugin {
    var interceptRequest: ((request: NSMutableURLRequest) -> Promise<NSMutableURLRequest>)? { get }
    var interceptRequestError: ((error: NSError) -> Promise<NSMutableURLRequest>)? { get }
    var interceptResponse: ((response: Response) -> Promise<Response>)? { get }
    var interceptResponseError: ((error: NSError) -> Promise<Response>)? { get }
}

public class PluginBase: Plugin {
    public var interceptRequest: ((request: NSMutableURLRequest) -> Promise<NSMutableURLRequest>)?
    public var interceptRequestError: ((error: NSError) -> Promise<NSMutableURLRequest>)?
    public var interceptResponse: ((response: Response) -> Promise<Response>)?
    public var interceptResponseError: ((error: NSError) -> Promise<Response>)?
}

public class Manager {
    private let requestHandler: RequestHandler
    private var plugins = [Plugin]()
    
    public class var sharedInstance: Manager {
        struct Shared {
            static let instance = Manager(HTTPRequestHandler)
        }
        return Shared.instance
    }
    
    public init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    public func addPlugin(plugin: Plugin) {
        self.plugins.append(plugin)
    }
    
    public func request(request: NSURLRequest) -> Promise<Response> {
        var mutableRequest = request.mutableCopy() as NSMutableURLRequest
        var requestPromise = Promise<NSMutableURLRequest>.resolve(mutableRequest)
        for plugin in self.plugins {
            if let intercept = plugin.interceptRequest {
                requestPromise = requestPromise.then(intercept)
            }
            if let intercept = plugin.interceptRequestError {
                requestPromise = requestPromise.catch(intercept)
            }
        }
        
        var responsePromise = requestPromise.then(self.requestHandler)
        
        for plugin in reverse(self.plugins) {
            if let intercept = plugin.interceptResponse {
                responsePromise = responsePromise.then(intercept)
            }
            
            if let intercept = plugin.interceptResponseError {
                responsePromise = responsePromise.catch(intercept)
            }
        }
        
        return responsePromise
    }
}

public func HTTPRequestHandler(request: NSURLRequest) -> Promise<Response> {
    return Promise<Response>({ (deferred) -> () in
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                deferred.resolve((request, response, data))
            } else {
                deferred.reject(error)
            }
        })
    })
}

