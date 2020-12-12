//
//  FeedItemsMapper.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 05/12/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation


internal struct RemoteFeedItemDTO: Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL
//
//    var feedItem: FeedItem {
//        return FeedItem(id: id, description: description, location: location, imageURL: image)
//    }
    
}

internal final class FeedItemsMapper {
    
    private struct FeedItemsResponse: Decodable {
        var items: [RemoteFeedItemDTO]
    }
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItemDTO] {
        guard response.statusCode == 200, let feedItemsResponse = try? JSONDecoder().decode(FeedItemsResponse.self, from: data) else {
            throw RemoteFeedLoader.RemoteError.invalidData
        }
        return feedItemsResponse.items
    }
}
