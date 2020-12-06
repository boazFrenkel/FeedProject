//
//  HTTPClientTests.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 05/12/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import XCTest
import TryFramework

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}
class URLSessionHTTPClientTests: XCTestCase {
    
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "https://any-url.com")!
        let sut = URLSessionHTTPClient()
        let error = NSError(domain: "any", code: 3)
        URLProtocolStub.stub(response: nil, data: nil, error: error)
        
        let expect = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(recievedError as NSError):
                XCTAssertEqual(recievedError, error)
            default:
                XCTFail("Ecpected failure with error \(error), got \(result) instead")
            }
            
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    
    // MARK: - Helpers
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        
        private struct Stub {
            let error: Error?
            let response: URLResponse?
            let data: Data?
        }
        
        static func stub(response: URLResponse?, data: Data?, error: Error?) {
            stub = Stub(error: error, response: response, data: data)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
    }
    
}
