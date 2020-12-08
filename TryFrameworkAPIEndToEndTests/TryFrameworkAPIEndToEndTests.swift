//
//  TryFrameworkAPIEndToEndTests.swift
//  TryFrameworkAPIEndToEndTests
//
//  Created by Boaz Frenkel on 06/12/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import XCTest
import TryFramework

class TryFrameworkAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
       
        let recievedResult = getFeedResult()
        switch recievedResult {
        case .success(let items):
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test account feed")
            XCTAssertEqual(items[0], expectedItem(at: 0))
            XCTAssertEqual(items[1], expectedItem(at: 1))
            XCTAssertEqual(items[2], expectedItem(at: 2))
            XCTAssertEqual(items[3], expectedItem(at: 3))
            XCTAssertEqual(items[4], expectedItem(at: 4))
            XCTAssertEqual(items[5], expectedItem(at: 5))
            XCTAssertEqual(items[6], expectedItem(at: 6))
            XCTAssertEqual(items[7], expectedItem(at: 7))
        case .failure(let error):
            XCTFail("Expected a succes result but got a\(error)")
        default:
            XCTFail("Expected a succes result but got no result")
        }
       
    }
    
    private func expectedItem(at index: Int) -> FeedItem {
        return FeedItem(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            imageURL: imageURL(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "sdfsdf434",
            "sfsd6sdf",
            "sfsdfhhbsdf",
            "sfsdffgfsdf",
            "sfs566dfsdf",
            "sfsd77fsdf",
            "sfsdyytg6fsdf",
            "sfsd678867hfsdf",
        ][index])!
    }
    
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> LoadFeedResult? {
        let client = URLSessionHTTPClient()
        let testServerURL = URL(string: "https://someServerAddress")!
        let loader = RemoteFeedLoader(url: testServerURL, httpClient: client)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        let exp = expectation(description: "wait for load completion")
        
        var recievedResult: LoadFeedResult?
        loader.load { result in
           recievedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return recievedResult
    }
    
    private func description(at index: Int) -> String {
        return  [
            "description 1",
            "description 2",
            "description 3",
            "description 4",
            "description 5",
            "description 6",
            "description 7",
            "description 8",
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return  URL(string: "https://url-\(index+1).com")!
    }
    
    private func location(at index: Int) -> String {
        return  [
            "a",
            "b",
            "d",
            "t",
            "y",
            "u",
            "i",
            "o",
        ][index]
    }
}
