//
//  SuccessURLProtocol.swift
//  
//  
//  Created by elmetal on 2021/07/16
//  
//

import Foundation

class SuccessURLProtocol: URLProtocol {
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
        guard let client = client, let url = request.url else {
            return
        }

        let headers: [String: String] = [
            "Content-Type": "application/json; charset=utf-8"
        ]
        let data = "{\"success\":true}\r\n".data(using: .utf8)

        if let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.0", headerFields: headers) {
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = data {
            client.urlProtocol(self, didLoad: data)
        }
        client.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
}
