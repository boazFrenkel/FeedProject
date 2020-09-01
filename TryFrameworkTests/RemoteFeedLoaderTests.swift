//
//  RemoteFeedLoaderTests.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 20/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import XCTest

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://blabla.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://blabla.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load  { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        let completion = { (error) in
            capturedErrors.append(error)
        }
        sut.load(completion: completion)
        
        let clientError = RemoteFeedLoader.Error.connectivity
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let clientErrorCodes = [400, 201, 300, 500, 900, 199]
        clientErrorCodes.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            let completion = { (error) in
                capturedErrors.append(error)
            }
            sut.load(completion: completion)
            client.complete(with: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://blabla.com")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, httpClient: client)
        return (remoteFeedLoader, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            let result = HTTPClientResult.error(error)
            self.messages[index].completion(result)
        }
        
        func complete(with statusCode: Int, at index: Int = 0) {
            
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: statusCode,
                                           httpVersion:nil,
                                           headerFields: nil
                )!
            let result = HTTPClientResult.success(response)
            self.messages[index].completion(result)
        }
    }
    
}
