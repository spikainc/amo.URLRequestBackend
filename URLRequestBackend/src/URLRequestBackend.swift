//
//  URLRequestBackend.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/14.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation

public protocol URLRequestPlugin {
    
}

public protocol URLRequestBackend {
    func sendRequest(request: NSURLRequest) -> NSURLResponse
}
