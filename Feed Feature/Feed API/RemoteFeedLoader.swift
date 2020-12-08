//
//  RemoteFeedLoader.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 22/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation


public typealias LoadFeedResult = Result<[FeedItem], Error>

public class RemoteFeedLoader: FeedLoader {
    public func load(_ completion: @escaping (LoadFeedResult) -> Void) {
        
        client.get(from: url) { (result) in
            
            switch result {
            case .success((let data, let response)):
                do {
                    let items = try FeedItemsMapper.map(data: data, response: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(RemoteError.invalidData))
                }
                
            case .failure(_):
                completion(.failure(RemoteError.connectivity))
            }
        }
    }
    

    private let client: HTTPClient
    private let url: URL
    
    public enum RemoteError: Error {
        case connectivity
        case invalidData
    }
    

    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.client = httpClient
    }
       
}
