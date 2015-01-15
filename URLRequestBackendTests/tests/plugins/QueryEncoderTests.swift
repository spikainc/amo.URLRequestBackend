//
//  QueryEncoderTests.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/15.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import XCTest
import URLRequestBackend

class QueryEncoderPluginTests: XCTestCase {
    var plugin: URLRequestBackend.Plugin.QueryEncoder!
    
    override func setUp() {
        super.setUp()
        plugin = URLRequestBackend.Plugin.QueryEncoder()
    }

}
