//
//  RemoteFeedLoaderTests.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 20/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import XCTest
@testable import TryFramework

typealias JSON = [String: Any]
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
        
        expect(sut: sut, toCompleteWith: .failure(.connectivity), whenGiven: {
            let clientError = NSError(domain: "error", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let clientErrorCodes = [400, 201, 300, 500, 900, 199]
        clientErrorCodes.enumerated().forEach { index, code in
            let json = makeItemsJson(items: [])
            expect(sut: sut, toCompleteWith: .failure(.invalidData), whenGiven: { client.complete(with: code, at: index, data: json) }
            )
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(.invalidData),whenGiven: {
            let invalidJson = Data("INVALID JSON".utf8)
            client.complete(with: 200, data: invalidJson)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut,
               toCompleteWith: .success([]),
               whenGiven: {
                let emptyListJsonData = makeItemsJson(items: [])
                client.complete(with: 200, data: emptyListJsonData)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithFullJsonList() {
        let (sut, client) = makeSUT()
        
        let feedItem1 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://google.com")!)
        
        let feedItem2 = FeedItem(id: UUID(), description: "description!!!!!", location: nil, imageURL: URL(string: "https://google.com")!)
        //        let feedItems = feedItemsResponse(items: [feedItem1, feedItem2])
        //        let encoder = JSONEncoder()
        //        let json = try! encoder.encode(feedItems)
        //
        let arrayOfItems = [createFeedItemJson(feedItem: feedItem1),
                            createFeedItemJson(feedItem: feedItem2)]
        
        expect(sut: sut,
               toCompleteWith: .success([feedItem1, feedItem2]),
               whenGiven: {
                
                let jsonData = makeItemsJson(items: arrayOfItems)
                client.complete(with: 200, data: jsonData)
        })
    }
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://blabla.com")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, httpClient: client)
        return (remoteFeedLoader, client)
    }
    
    private func expect(sut: RemoteFeedLoader,
                        toCompleteWith result: RemoteFeedLoader.LoadFeedResult,
                        whenGiven action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.LoadFeedResult]()
        let completion = { (error) in
            capturedResults.append(error)
        }
        sut.load(completion: completion)
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line:  line)
    }
    
    private func createFeedItemJson(feedItem: FeedItem) -> JSON {
        let json: JSON = ["id": "\(feedItem.id.uuidString)", "image": "\(feedItem.imageURL.absoluteString)", "description": feedItem.description as Any, "location": feedItem.location as Any ]
        
        let goodJ: JSON = json.compactMapValues { value in
            
            return value
            
        }
        return goodJ
    }
    
    private func makeItemsJson(items: [JSON]) -> Data {
        let items = ["items": items]
        let jsonData = try! JSONSerialization.data(withJSONObject: items)
        return jsonData
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
        
        func complete(with statusCode: Int, at index: Int = 0, data: Data) {
            
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: statusCode,
                                           httpVersion:nil,
                                           headerFields: nil
                )!
            
            let result = HTTPClientResult.success(response, data)
            self.messages[index].completion(result)
        }
    }
    
}
