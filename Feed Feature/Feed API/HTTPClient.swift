//
//  HTTPClient.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 05/12/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
    
}
