//
//  HTTPClientTests.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 05/12/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import XCTest
import TryFramework

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = URL(string: "https://any-url.com")!
        let sut = makeSUT()
        let expect = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { (request) in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.httpMethod, "GET")
            expect.fulfill()
        }
        sut.get(from: url) { _ in }
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
       
        let url = URL(string: "https://any-url.com")!
        let sut = makeSUT()
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
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "SUT should jave been deallocated ptential memory leak", file: file, line: line)
        }
    }
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        private struct Stub {
            let error: Error?
            let response: URLResponse?
            let data: Data?
        }
        
        static func stub(response: URLResponse?, data: Data?, error: Error?) {
            stub = Stub(error: error, response: response, data: data)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            URLProtocolStub.requestObserver = observer
        }
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
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
