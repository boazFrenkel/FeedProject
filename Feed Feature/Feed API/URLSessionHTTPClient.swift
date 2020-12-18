//
//  URLSessionHTTPClient.swift
//  TryFramework
//
//  Created by Boaz Frenkel on 07/12/2020.
//  Copyright © 2020 BoazFrenkel. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}


/*
 IF we want a moya http client:

 public class MoyaHTTPClient: HTTPClient {

     private let provider: MoyaProvider<FeedProvider>
     
     public init(provider: MoyaProvider<FeedProvider> = MoyaProvider<FeedProvider>(plugins: [NetworkLoggerPlugin.init()])) {
         self.provider = provider
     }
     
     private struct UnexpectedValuesRepresentation: Error {}
     
     public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
         provider.request(.getFeedItems) { result in
             switch result {
             case .success(let response):
                 guard let httpResponse = response.response else {
                     return completion(.failure(UnexpectedValuesRepresentation()))
                 }
                 completion(.success((response.data, httpResponse)))
             case .failure(let error):
                 completion(.failure(error))
             }
         }
     }
 }

 public enum FeedProvider {
     case getFeedItems
     
 }

 extension FeedProvider: TargetType {
     
     public var baseURL: URL {
         switch self {
         case .getFeedItems:
             return URL(string: "Feed base url")!
         }
     }
     
     public var path: String {
         return "getFeedItems path"
     }
     
     public var method: Moya.Method {
         return .get
     }
     
     public var task: Task {
         switch self {
         case .getFeedItems:
             return .requestPlain
         }
     }
     
     public var headers: [String: String]? {
         return [:]
     }
     
     public var validationType: ValidationType {
         return .successCodes
     }
     
     public var sampleData: Data {
         return Data()
     }
 }
 
*/
