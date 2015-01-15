//
//  UtilTests.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/15.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation
import XCTest
import URLRequestBackend

class UtilTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func parametersで渡した値がURL内にクエリとして入るDataProvider() -> [([String: AnyObject], String)] {
        return [
            (["a": "b", "c": "d"], "a=b&c=d"),
            (["a": ["b", "c", "d"]], "a[]=b&a[]=c&a[]=d"),
            (["a": ["b": "c", "d": "e"]], "a[b]=c&a[d]=e"),
            (["a": ["b": ["c", "d"]]], "a[b][]=c&a[b][]=d"),
            ([" !\"#$%&'()*+,/:;<=>?@[\\]^`{|}": " !\"#$%&'()*+,/:;<=>?@[\\]^`{|}"], "%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F%3A%3B%3C%3D%3E%3F%40%5B%5C%5D%5E%60%7B%7C%7D=%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F%3A%3B%3C%3D%3E%3F%40%5B%5C%5D%5E%60%7B%7C%7D"),
        ]
    }
    func test_parametersで渡した値がURL内にクエリとして入る() {
        for params in self.parametersで渡した値がURL内にクエリとして入るDataProvider() {
            let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8000/")!)
            let actual = URLRequestBackend.Util.escapeParameters(params.0)
            XCTAssertEqual(params.1, actual)
        }
    }
}
