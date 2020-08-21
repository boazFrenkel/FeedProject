//
//  RemoteFeedLoaderTests.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 20/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import XCTest

class RemoteFeedLoader {
    var httpClient: HTTPClientProtocol
    
    init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }
    
    func load() {
        let url = URL(string: "https://blabla.com")
        httpClient.get(from: url!)//requestedURL = URL(string: "https://blabla.com")
    }
//    func load(complition: @escaping (LoadFeedResult) -> Void) {
//        self.httpClient.requestedURL = URL()
//    }
}

protocol HTTPClientProtocol {
    //var requestedURL: URL? {get set}
    
    func get(from url: URL)
}

class HTTPClient: HTTPClientProtocol {
    
    
    func get(from url: URL) { }
}

class HTTPClientSpy: HTTPClientProtocol {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(httpClient: client)
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(httpClient: client)
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
