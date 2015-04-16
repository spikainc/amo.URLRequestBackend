//
//  FormURLEncoderTests.swift
//  URLRequestBackend
//
//  Created by 林達也 on 2015/03/09.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import UIKit
import XCTest
import URLRequestBackend

class FormURLEncoderTests: XCTestCase {
    var plugin: URLRequestBackend.Plugin.FormURLEncoder!
    
    override func setUp() {
        super.setUp()
        plugin = URLRequestBackend.Plugin.FormURLEncoder()
    }

    func test_requestがPOST() {
        plugin = URLRequestBackend.Plugin.FormURLEncoder()
        
        let urlrequest = NSMutableURLRequest(URL: NSURL(string: "http://www.json.org")!)
        let request = Request(
            request: urlrequest,
            context: [
                "parameters": [
                    "a": "b"
                ]
            ]
        )
        
        let parameters = request.context?["parameters"] as? [String: AnyObject]
        let query = Util.escapeParameters(parameters!)
        let data = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        let actual = self.plugin.interceptRequest(request)
        
        XCTAssertEqual(actual.request.valueForHTTPHeaderField("Content-Length")!, "\(data.length)", "")
        XCTAssertEqual(actual.request.HTTPMethod, "POST", "")
    }
    
    func test_dataの比較() {
        
    }
}
