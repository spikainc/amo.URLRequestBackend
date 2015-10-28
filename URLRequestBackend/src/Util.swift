//
//  Util.swift
//  URLRequestBackend
//
//  Created by 安野周太郎 on 2015/01/15.
//  Copyright (c) 2015年 amo. All rights reserved.
//

import Foundation

public struct Util {
    public static func escapeParameters(parameters: [String : AnyObject]) -> String {
        var components = [String]()
        for (key, value) in parameters {
            components += escapeComponents(key, value)
        }
        
        return components.joinWithSeparator("&")
    }
    
    public static func escapeComponents(key: String, _ value: AnyObject) -> [String] {
        var components = [String]()
        if let d = value as? [String: AnyObject] {
            for (k, v) in d {
                components += escapeComponents("\(key)[\(k)]", v)
            }
        } else if let a = value as? [AnyObject] {
            for v in a {
                components += escapeComponents("\(key)[]", v)
            }
        } else {
            let s = "\(value)"
            components.append("\(escapeString(key))=\(escapeString(s))")
        }
        return components
    }
    
    public static func escapeString(s: String) -> String {
        return CFURLCreateStringByAddingPercentEscapes(nil, s, nil, " !\"#$%&'()*+,/:;<=>?@[\\]^`{|}", CFStringBuiltInEncodings.UTF8.rawValue) as! String
    }
}
