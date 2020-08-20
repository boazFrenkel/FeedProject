//
//  FeedLoader.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 20/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation
enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}
protocol FeedLoader {
    func load(complition: @escaping (LoadFeedResult) -> Void)
}
