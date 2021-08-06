//
//  FeedIMage.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 13/09/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public struct FeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
