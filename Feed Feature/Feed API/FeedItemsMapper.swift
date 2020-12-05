//
//  FeedItemsMapper.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 05/12/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public class FeedItemsMapper {
    
    private struct FeedItemDTO: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
        
    }
    
    private struct FeedItemsResponse: Decodable {
        var items: [FeedItemDTO]
    }
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.RemoteError.invalidData
        }
        
        let decoder = JSONDecoder()
        let items = try decoder.decode(FeedItemsResponse.self, from: data).items
        return items.map { $0.feedItem }
    }
}
