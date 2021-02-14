//
//  FeedLoader.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 20/08/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(_ completion: @escaping (Result) -> Void)
}

