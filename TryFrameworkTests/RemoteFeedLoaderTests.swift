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
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://blabla.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        
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
        client.triggerCompletion(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://blabla.com")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, httpClient: client)
        return (remoteFeedLoader, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (Error) -> Void)] = []
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func triggerCompletion(with error: Error, at index: Int = 0) {
            self.messages[index].completion(error)
        }
    }
    
}
