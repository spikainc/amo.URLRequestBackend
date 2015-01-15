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
            (["a": ["b", "c", "d"]], "a%5B%5D=b&a%5B%5D=c&a%5B%5D=d"),
            (["a": ["b": "c", "d": "e"]], "a%5Bb%5D=c&a%5Bd%5D=e"),
            (["a": ["b": ["c", "d"]]], "a%5Bb%5D%5B%5D=c&a%5Bb%5D%5B%5D=d"),
            ([" !\"#$%&'()*+,/:;<=>?@[\\]^`{|}": " !\"#$%&'()*+,/:;<=>?@[\\]^`{|}"], "%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F%3A%3B%3C%3D%3E%3F%40%5B%5C%5D%5E%60%7B%7C%7D=%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F%3A%3B%3C%3D%3E%3F%40%5B%5C%5D%5E%60%7B%7C%7D"),
            ([
                "str": "b",
                "num": 100,
                "strnum": "100",
                "array": ["a", "b", "c"],
                "dict": ["hoge": "fuga", "fizz": "buzz"],
                "recursive": [
                    "str": "b",
                    "num": 100,
                    "strnum": "100",
                    "array": ["a", "b", "c"],
                    "dict": ["hoge": "fuga", "fizz": "buzz"],
                ],
                "recursiveArray": [
                    [
                        "str": "b",
                        "num": 100,
                        "strnum": "100",
                        "array": ["a", "b", "c"],
                        "dict": ["hoge": "fuga", "fizz": "buzz"],
                    ], [
                        "str": "b",
                        "num": 100,
                        "strnum": "100",
                        "array": ["a", "b", "c"],
                        "dict": ["hoge": "fuga", "fizz": "buzz"],
                    ], [
                        "str": "b",
                        "num": 100,
                        "strnum": "100",
                        "array": ["a", "b", "c"],
                        "dict": ["hoge": "fuga", "fizz": "buzz"],
                    ],
                ]
            ], "str=b&num=100&strnum=100&array%5B%5D=a&array%5B%5D=b&array%5B%5D=c&dict%5Bhoge%5D=fuga&dict%5Bfizz%5D=buzz&recursive%5Bstr%5D=b&recursive%5Bnum%5D=100&recursive%5Bstrnum%5D=100&recursive%5Barray%5D%5B%5D=a&recursive%5Barray%5D%5B%5D=b&recursive%5Barray%5D%5B%5D=c&recursive%5Bdict%5D%5Bhoge%5D=fuga&recursive%5Bdict%5D%5Bfizz%5D=buzz&recursiveArray%5B%5D%5Bstr%5D=b&recursiveArray%5B%5D%5Bnum%5D=100&recursiveArray%5B%5D%5Bstrnum%5D=100&recursiveArray%5B%5D%5Barray%5D%5B%5D=a&recursiveArray%5B%5D%5Barray%5D%5B%5D=b&recursiveArray%5B%5D%5Barray%5D%5B%5D=c&recursiveArray%5B%5D%5Bdict%5D%5Bhoge%5D=fuga&recursiveArray%5B%5D%5Bdict%5D%5Bfizz%5D=buzz&recursiveArray%5B%5D%5Bstr%5D=b&recursiveArray%5B%5D%5Bnum%5D=100&recursiveArray%5B%5D%5Bstrnum%5D=100&recursiveArray%5B%5D%5Barray%5D%5B%5D=a&recursiveArray%5B%5D%5Barray%5D%5B%5D=b&recursiveArray%5B%5D%5Barray%5D%5B%5D=c&recursiveArray%5B%5D%5Bdict%5D%5Bhoge%5D=fuga&recursiveArray%5B%5D%5Bdict%5D%5Bfizz%5D=buzz&recursiveArray%5B%5D%5Bstr%5D=b&recursiveArray%5B%5D%5Bnum%5D=100&recursiveArray%5B%5D%5Bstrnum%5D=100&recursiveArray%5B%5D%5Barray%5D%5B%5D=a&recursiveArray%5B%5D%5Barray%5D%5B%5D=b&recursiveArray%5B%5D%5Barray%5D%5B%5D=c&recursiveArray%5B%5D%5Bdict%5D%5Bhoge%5D=fuga&recursiveArray%5B%5D%5Bdict%5D%5Bfizz%5D=buzz"),
        ]
    }
    func test_parametersで渡した値がURL内にクエリとして入る() {
        for params in self.parametersで渡した値がURL内にクエリとして入るDataProvider() {
            let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8000/")!)
            let expected = params.1
            let actual = URLRequestBackend.Util.escapeParameters(params.0)
            XCTAssertEqual(sorted((split(expected, { $0 == "&"}))), sorted((split(actual, { $0 == "&"}))))
        }
    }
}
