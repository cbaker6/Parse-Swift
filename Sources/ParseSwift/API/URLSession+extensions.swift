//
//  URLSession+extensions.swift
//  ParseSwift
//
//  Original file, URLSession+async.swift, created by Florent Vilmart on 17-09-24.
//  Name change to URLSession+extensions.swift and support for sync/async by Corey Baker on 7/25/20.
//  Copyright © 2020 Parse Community. All rights reserved.
//

import Foundation

extension URLSession {

    internal func dataTask(with request: URLRequest, callbackQueue: DispatchQueue?,
                           completion: @escaping(Result<Data, ParseError>) -> Void) {

        func makeResult(responseData: Data?, urlResponse: URLResponse?,
                        responseError: Error?) -> Result<Data, ParseError> {
            if let responseData = responseData {
                return .success(responseData)
            } else if let responseError = responseError {
                return .failure(ParseError(code: .unknownError, message: "Unable to sync: \(responseError)"))
            } else {
                return .failure(ParseError(code: .unknownError,
                                           message: "Unable to sync: \(String(describing: urlResponse))."))
            }
        }

        dataTask(with: request) { (responseData, urlResponse, responseError) in
            let result = makeResult(responseData: responseData, urlResponse: urlResponse, responseError: responseError)

            if let callbackQueue = callbackQueue {
                callbackQueue.async { completion(result) }
            } else {
                completion(result)
            }
        }.resume()
    }
}
