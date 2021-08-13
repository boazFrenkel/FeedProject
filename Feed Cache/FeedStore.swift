//
//  FeedStore.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 06/08/2021.
//  Copyright © 2021 BoazFrenkel. All rights reserved.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrivelCompletions = (Result<[LocalFeedImage], Error>) -> Void
   
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertFeed(_ feed: [LocalFeedImage], timestemp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrivelCompletions)
}
