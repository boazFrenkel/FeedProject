//
//  RemoteFeedLoader.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 22/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
    
}

public final class RemoteFeedLoader {
    private let httpClient: HTTPClient
    private let url: URL
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load() {
        // let url = URL(string: "https://blabla.com")
        httpClient.get(from: url)//requestedURL = URL(string: "https://blabla.com")
    }
    //    func load(complition: @escaping (LoadFeedResult) -> Void) {
    //        self.httpClient.requestedURL = URL()
    //    }
}


