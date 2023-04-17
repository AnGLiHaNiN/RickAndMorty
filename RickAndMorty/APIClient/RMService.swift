//
//  RMService.swift
//  RickAndMorty
//
//  Created by Михаил on 17.04.2023.
//

import Foundation

/// Primary API service object to get Rick and Morty data
final class RMService {
    
    /// Shared singleton instance
    static let shared = RMService()
    
    /// Privatized constructor
    private init() {}
    
    
    
    /// Send Rick and Morty API Call
    /// - Parameters:
    ///   - request: Request instance
    ///   - type: The type of object we expect to get back 
    ///   - complition: Callback with data or error
    public func execute<T: Codable>(
        _ request: RMRequest,
        expecting type: T.Type,
        complition: @escaping (Result<T, Error>) -> Void)
    {
         
    }
}
