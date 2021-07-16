//
//  ErrorURLProtocol.swift
//  
//  
//  Created by elmetal on 2021/07/16
//  
//

import Foundation

class ErrorURLProtocol: URLProtocol {
    static var error = URLError(.badURL)
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ lhs: URLRequest, to rhs: URLRequest) -> Bool {
        return false
    }

    override func startLoading() {
        guard let client = client else { return }

        client.urlProtocol(self, didFailWithError: ErrorURLProtocol.error)
    }

    override func stopLoading() {
    }
}
