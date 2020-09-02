//
//  RemoteFeedLoader.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 22/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public struct feedItemsResponse: Codable {
    var items: [FeedItem]
}
public struct FeedItem: Equatable, Codable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
    
}

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case error(Error)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum LoadFeedResult: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.client = httpClient
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url) { (result) in
            
            switch result {
            case .success(_, let data):
                let decoder = JSONDecoder()
                if let items = try? decoder.decode(feedItemsResponse.self, from: data).items {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .error:
                completion(.failure(.connectivity))
            }
        }
    }
}



/* if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
    completion(
}
break
 */
