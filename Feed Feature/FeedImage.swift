//
//  FeedItem.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 13/09/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public struct FeedImage: Equatable, Codable {
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
}
