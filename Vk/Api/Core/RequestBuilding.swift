//
//  RequestBuilder.swift
//
//  Created by Andrey on 06.05.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

enum RequestBuildError: Error {
    case badURL
}

protocol RequestBuilding {
    var urlRequest: URLRequest? { get }
}

extension BaseRequest: RequestBuilding {
    var urlRequest : URLRequest? {
        guard let url = self.url else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = self.method.rawValue
        req.httpBody = httpBody        
        req.timeoutInterval = 15
        req.allHTTPHeaderFields = ApiConfig.headers
        if headers.count > 0 { for (key, value) in headers { req.allHTTPHeaderFields![key] = value } }
        return req
    }

    private var url : URL? {
        guard let baseURL = URL(string: ApiConfig.baseUrl) else { return nil }
        guard var URLComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else { return nil }
        URLComponents.path = URLComponents.path + pathWithParams
        URLComponents.queryItems = parametersAsQueryItems
        return URLComponents.url
    }

    private var pathWithParams : String {
        var str = self.path
        if pathParams.count > 0 {
            for (k, v) in pathParams { str = str.replacingOccurrences(of: "{\(k)}", with: "\(v)") }
        }
        return str
    }

    private var parametersAsQueryItems : Array<URLQueryItem>? {
        return queryParams.count == 0 ? nil : queryParams.map { (key, value) in URLQueryItem(name: key, value: (value as AnyObject).description) }
    }    

    private var httpBody : Data? {
        if body.count > 0 {
            headers["Content-Type"] = "application/json"
            return try? JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        else if files.count > 0 {
            headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
            var body = Data()
            for (k, v) in files {
                let key = k.components(separatedBy: "|").first!
                let filename = k.components(separatedBy: "|").last!
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
                body.append(v)
                body.append("\r\n".data(using: .utf8)!)
            }
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            return body
        }
        return nil
    }

    private var boundary : String { return "~-=-=-=-~" }
}
