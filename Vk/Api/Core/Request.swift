//
//  Request.swift
//
//  Created by Andrey on 06.05.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class BaseRequest: NSObject {
    var method = RequestMethod.get
    var path = ""
    var pathParams = [String:Any]()
    var queryParams = [String:Any]()
    var body = [String:Any]()
    var headers = [String:String]()
    var files = [String:Data]()
}
