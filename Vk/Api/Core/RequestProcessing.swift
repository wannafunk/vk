//
//  RequestProcessing.swift
//
//  Created by Andrey on 23.05.16.
//  Copyright © 2016y. All rights reserved.
//

import Foundation
import ObjectMapper

extension Notification.Name {
    static let requestFailedWithInvalidToken = Notification.Name("requestFailedWithInvalidToken")
}

protocol Bindable: RequestBuilding, RequestSending {
    associatedtype ResponseType
    func exec(timeout: TimeInterval, completion: @escaping (_ result: Result<Response<ResponseType>>) -> Void)
}

struct Response<T> {
    var array : [T]
    var object : T { return array.first! }
}

extension Bindable where ResponseType : Mappable {
    
    func exec(timeout: TimeInterval = 15, completion: @escaping (_ result: Result<Response<ResponseType>>) -> Void) {
        guard let urlRequest = self.urlRequest else { completion(Result.error(RequestBuildError.badURL)); return }
        print("-> \(urlRequest.httpMethod!) \(urlRequest.url!.absoluteString)")

        var req = urlRequest
        req.timeoutInterval = timeout
        
        send(request: req) { result in
            switch result {
            case .error(let error):
                completion(Result.error(error))
            case .value(let tuple):
                do {
                    let response = try self.processRequest(request: req, httpResponse: tuple.0, data: tuple.1)
                    completion(Result.value(response))
                }
                catch let error {
                    completion(Result.error(error))
                }
            }
        }
    }
    
    private func processRequest(request: URLRequest, httpResponse: HTTPURLResponse?, data: Data) throws -> Response<ResponseType> {
        print("<- \(request.httpMethod!) \(request.url!.absoluteString) [\(httpResponse!.statusCode)]")
        if let JSONString = String(data: data, encoding: .utf8) {
            print("\(JSONString)")
            
            if httpResponse == nil || (httpResponse!.statusCode >= 200 && httpResponse!.statusCode < 300)
            {
                if JSONString.hasPrefix("[") {
                    if let array = Mapper<ResponseType>().mapArray(JSONString: JSONString) { return Response<ResponseType>(array: array) }
                }
                else {
                    let JSONString = JSONString.count > 0 ? JSONString : "{}"
                    if let object = Mapper<ResponseType>().map(JSONString: JSONString) { return Response<ResponseType>(array: [object]) }
                }
            }
            else {
                if let error = Mapper<NetworkError>().map(JSONString: JSONString) { throw error }
            }
        }
        throw URLError(.badServerResponse)
    }
}
