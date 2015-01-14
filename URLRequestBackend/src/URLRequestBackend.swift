//
//  URLRequestBackend.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/14.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import Promise

public typealias URLResponse = (request: NSURLRequest, response: NSURLResponse, data: NSData)
public typealias URLRequestHandler = (request: NSURLRequest) -> Promise<URLResponse>

public protocol URLRequestPlugin {
    var interceptRequest: ((request: NSMutableURLRequest) -> Promise<NSMutableURLRequest>)? { get }
    var interceptRequestError: ((error: NSError) -> Promise<NSMutableURLRequest>)? { get }
    var interceptResponse: ((response: URLResponse) -> Promise<URLResponse>)? { get }
    var interceptResponseError: ((error: NSError) -> Promise<URLResponse>)? { get }
}

public class URLRequestBackend {
    private let defaultRequestHandler: URLRequestHandler
    private var plugins = [URLRequestPlugin]()
    
    public init(defaultRequestHandler: URLRequestHandler) {
        self.defaultRequestHandler = defaultRequestHandler
    }
    
    public func addPlugin(plugin: URLRequestPlugin) {
        self.plugins.append(plugin)
    }
    
    public func request(request: NSURLRequest, requestHandler: URLRequestHandler! = nil) -> Promise<URLResponse> {
        var sendRequest = self.defaultRequestHandler
        if requestHandler != nil {
            sendRequest = requestHandler!
        }
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
        
        var responsePromise = requestPromise.then(sendRequest)
        
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

public func HTTPRequestHandler(request: NSURLRequest) -> Promise<URLResponse> {
    return Promise<URLResponse>({ (deferred) -> () in
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

