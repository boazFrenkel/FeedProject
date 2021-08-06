//
//  LocalFeedImage.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 06/08/2021.
//  Copyright © 2021 BoazFrenkel. All rights reserved.
//

import Foundation

public class LocalFeedImage: Equatable {
    public static func == (lhs: LocalFeedImage, rhs: LocalFeedImage) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = imageURL
    }
}
