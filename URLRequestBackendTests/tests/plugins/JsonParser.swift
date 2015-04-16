//
//  JsonParser.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/15.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import XCTest
import URLRequestBackend

class JSONParserPluginTests: XCTestCase {
    var plugin: URLRequestBackend.Plugin.JsonParser!
    
    override func setUp() {
        super.setUp()
        self.plugin = URLRequestBackend.Plugin.JsonParser()
    }
    
    func test_parseを使ってJSONをparseできる() {
        let body = "{\"a\": \"b\"}"
        let data = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        let (json: AnyObject?, error) = self.plugin.parse(data)
        XCTAssertNotNil(json)
        XCTAssertEqual("b", json?["a"] as! String)
    }
}
