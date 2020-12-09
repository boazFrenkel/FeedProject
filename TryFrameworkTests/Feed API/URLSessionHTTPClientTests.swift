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
    
//    func test_getFromURL_performsGETRequestWithURL() {
//        resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line)
////        let url = URL(string: "https://any-url.com")!
////        let sut = makeSUT()
////        let expect = expectation(description: "Wait for request")
////        URLProtocolStub.observeRequests { (request) in
////            XCTAssertEqual(request.url, url)
////            XCTAssertEqual(request.httpMethod, "GET")
////            XCTAssertEqual(request.httpMethod, "GET")
////            expect.fulfill()
////        }
////        sut.get(from: url) { _ in }
////        wait(for: [expect], timeout: 1.0)
//    }
    
    func test_getFromURL_failsOnRequestError() {
       
        let url = anyURL()
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
        
        wait(for: [expect], timeout: 5.0)
    }
    
    func test_getFromURL_failsOnAllNilValues() {
       
        let url = anyURL()
        let sut = makeSUT()
        URLProtocolStub.stub(response: nil, data: nil, error: nil)
        
        let expect = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case .failure(_):
                break
            default:
                XCTFail("Ecpected failure but got \(result) instead")
            }
            
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let url = anyURL()
        let sut = makeSUT()
        URLProtocolStub.stub(response: response, data: data, error: nil)
        
        let expect = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case .success((let recievedData, let recievedResponse)):
                XCTAssertEqual(recievedData, data)
                XCTAssertEqual(recievedResponse.url, response.url)
                XCTAssertEqual(recievedResponse.statusCode, response.statusCode)
            case .failure(_):
                XCTFail("Ecpected success but got \(result) instead")
            }
            
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1.0)
    }
    
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let recievedValues = resultValuesFor(data: nil, response: response, error: nil)
    
        let emptyData = Data()
        XCTAssertEqual(recievedValues?.data, emptyData)
        XCTAssertEqual(recievedValues?.response.url, response.url)
        XCTAssertEqual(recievedValues?.response.statusCode, response.statusCode)
        
    }
    
    
    // MARK: - Helpers
    //private func result
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case .success(_):
            XCTFail("Expected failure but got \(result) instead", file: file, line:  line)
            return nil
        case .failure(let error):
            return error
        }
        
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case .success((let data, let response)):
            return (data, response)
        case .failure(_):
            XCTFail("Expected failure but got \(result) instead", file: file, line:  line)
            return nil
        }
        
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        let url = anyURL()
        let sut = makeSUT()
        URLProtocolStub.stub(response: response, data: data, error: nil)

        let expect = expectation(description: "Wait for request")
        
        var recievedResult: HTTPClientResult!
        sut.get(from: url) { result in
            recievedResult = result
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)
        return recievedResult
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any", code: 3)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
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
