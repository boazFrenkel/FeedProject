//
//  RemoteFeedLoader.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 22/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
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
    
    public func load(_ completion: @escaping (FeedLoader.Result) -> Void) {
        
        client.get(from: url) { (result) in
            
            switch result {
            case .success((let data, let response)):
                completion(RemoteFeedLoader.map(data, from: response))
                
            case .failure(_):
                completion(.failure(RemoteError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
        do {
            let items = try FeedItemsMapper.map(data: data, response: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
    
}


private extension Array where Element == RemoteFeedItemDTO {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
