//
//  FeedStoreSpy.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 06/08/2021.
//  Copyright © 2021 BoazFrenkel. All rights reserved.
//

import Foundation
import TryFramework

class FeedStoreSpy: FeedStore {
    
    enum RecievedMessage: Equatable {
        case deleteCachedFeed
        case insertFeed( [LocalFeedImage], Date)
    }
    
    private(set) var recievedMessages = [RecievedMessage]()
    private var deletionCompletions: [FeedStore.DeletionCompletion] = []
    private var insertionCompletions: [FeedStore.InsertionCompletion] = []
    
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        self.deletionCompletions.append(completion)
        recievedMessages.append(RecievedMessage.deleteCachedFeed)
    }
    
    func insertFeed(_ feed: [LocalFeedImage], timestemp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insertFeed(feed, timestemp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfuly(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertionSuccessfuly(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
}
