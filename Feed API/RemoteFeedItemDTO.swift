//
//  RemoteFeedItemDTO.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 12/12/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

internal struct RemoteFeedItemDTO: Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL
}
