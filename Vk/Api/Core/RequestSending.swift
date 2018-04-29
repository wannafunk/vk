//
//  RequestViaURLSession.swift
//
//  Created by Andrey on 10.05.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

protocol RequestSending {
    func send(request: URLRequest, completion: @escaping (_ result: Result<(HTTPURLResponse, Data)>) -> Void)
}

protocol RequestSendingWithDelegate: RequestSending, URLSessionTaskDelegate {}

extension RequestSending {
    func send(request: URLRequest, completion: @escaping (_ result: Result<(HTTPURLResponse, Data)>) -> Void) {
        if request.url == nil { completion(Result.error(RequestBuildError.badURL)); return }
        sendRequest(request: request, session: URLSession.shared, completion: completion)
    }

    func sendRequest(request: URLRequest, session: URLSession, completion: @escaping (_ result: Result<(HTTPURLResponse, Data)>) -> Void) {
        session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error { completion(Result.error(error)) }
                else { completion(Result.value((response as! HTTPURLResponse, data!))) }
            }
            }.resume()
    }
}

extension RequestSendingWithDelegate {
    func send(request: URLRequest, completion: @escaping (_ result: Result<(HTTPURLResponse, Data)>) -> Void) {
        if request.url == nil { completion(Result.error(RequestBuildError.badURL)); return }
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        sendRequest(request: request, session: session, completion: completion)
    }
}
