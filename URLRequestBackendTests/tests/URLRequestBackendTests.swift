//
//  URLRequestBackendTests.swift
//  URLRequestBackendTests
//
//  Created by 安野周太郎 on 2015/01/14.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import UIKit
import XCTest
import URLRequestBackend

class URLRequestBackendTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_sharedInstanceは同じインスタンスを返す() {
        XCTAssertTrue(URLRequestBackend.Manager.sharedInstance === URLRequestBackend.Manager.sharedInstance)
    }
}
