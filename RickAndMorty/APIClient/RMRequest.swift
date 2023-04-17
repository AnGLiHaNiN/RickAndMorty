//
//  RMRequest.swift
//  RickAndMorty
//
//  Created by Михаил on 17.04.2023.
//

import Foundation


/// Object represents a single API call
final class RMRequest {
    
    
    /// API Constants
    private struct Constants {
        static let baseUrl = "https://rickandmortyapi.com/api"
    }
    
    /// Desired endpoint
    private let endpoint: RMEndpoint
    /// Path components for API. if any
    private let pathComponents: Set<String>
    /// Query components for API, if any
    private let queryParametrs: [URLQueryItem]
    
    
    /// Constructed url fore the api request in string format
    private var urlString: String {
        var string = Constants.baseUrl
        string += "/"
        string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach {
                string += "/\($0)"
            }
        }
        
        if !queryParametrs.isEmpty {
            string += "?"
            let argumentString = queryParametrs.compactMap {
                guard let value = $0.value else {return nil}
                return "\($0.name)=\(value)"
            }.joined(separator: "&")
            
            string += argumentString
        }
        
        return string
    }
    
    public var url: URL? {
        return URL(string: urlString)
    }
    
    public let httpMethod = "GET"
    
    
    // MARK: -Public
    
    
    /// Construct request
    /// - Parameters:
    ///   - endpoint: Target endpoint
    ///   - pathComponents: Collection of Path components
    ///   - queryParametrs: Collection of query parameters
    public init(
        endpoint: RMEndpoint,
        pathComponents: Set<String> = [],
        queryParametrs: [URLQueryItem] = [])
    {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParametrs = queryParametrs
    }
    
}
