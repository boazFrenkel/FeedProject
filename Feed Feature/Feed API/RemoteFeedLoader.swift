//
//  RemoteFeedLoader.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 22/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
    
}

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case error(Error)
}
public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.client = httpClient
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { (result) in
            
            switch result {
            case .success:
                completion(.invalidData)
            case .error:
                completion(.connectivity)
            }
        }
    }
}


