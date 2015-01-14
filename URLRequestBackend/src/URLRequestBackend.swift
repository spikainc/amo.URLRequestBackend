//
//  URLRequestBackend.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/14.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import Promise

public typealias Result = (request: NSURLRequest, response: NSURLResponse, data: AnyObject?)
public typealias RequestHandler = (request: NSURLRequest) -> Promise<Result>

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
    
    public func request(request: NSURLRequest) -> Promise<Result> {
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
            if let intercept = plugin.interceptResult {
                responsePromise = responsePromise.then(intercept)
            }
            
            if let intercept = plugin.interceptResultError {
                responsePromise = responsePromise.catch(intercept)
            }
        }
        
        return responsePromise
    }
}

public func HTTPRequestHandler(request: NSURLRequest) -> Promise<Result> {
    return Promise<Result>({ (deferred) -> () in
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

public protocol PluginProtocol {
    var interceptRequest: ((request: NSMutableURLRequest) -> Promise<NSMutableURLRequest>)? { get }
    var interceptRequestError: ((error: NSError) -> Promise<NSMutableURLRequest>)? { get }
    var interceptResult: ((result: Result) -> Promise<Result>)? { get }
    var interceptResultError: ((error: NSError) -> Promise<Result>)? { get }
}

public struct Plugin {
    public class Base: PluginProtocol {
        public init() {}
        public var interceptRequest: ((request: NSMutableURLRequest) -> Promise<NSMutableURLRequest>)?
        public var interceptRequestError: ((error: NSError) -> Promise<NSMutableURLRequest>)?
        public var interceptResult: ((result: Result) -> Promise<Result>)?
        public var interceptResultError: ((error: NSError) -> Promise<Result>)?
    }
}

extension Plugin {
    public class JsonParser: Base {
        let option: NSJSONReadingOptions
        public init(option: NSJSONReadingOptions = .AllowFragments) {
            self.option = option
            super.init()
            self.interceptResult = self._interceptResult
        }
        
        func _interceptResult(result: Result) -> Promise<Result> {
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

