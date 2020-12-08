//
//  TrackMemoryLeaksHelper.swift
//  TryFrameworkTests
//
//  Created by Boaz Frenkel on 08/12/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import XCTest

extension XCTestCase {
 
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "SUT should jave been deallocated ptential memory leak", file: file, line: line)
        }
    }
}
