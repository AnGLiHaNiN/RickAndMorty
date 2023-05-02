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
    
    
    enum RMServiceError: Error {
        case failedToCreateRequest
        case filedToGetData
    }
    
    
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
        guard let urlRequest = self.request(from: request) else {
            complition(.failure(RMServiceError.failedToCreateRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            guard let data = data, error == nil else {
                complition(.failure(error ?? RMServiceError.filedToGetData))
                return
            }
            
            do {
                //let json = try JSONSerialization.jsonObject(with: data) тут была просто проверка
                let result = try JSONDecoder().decode(type.self, from: data)
                complition(.success(result))
            } catch  {
                complition(.failure(error))
            }
        }
        task.resume() 
    }
    
    //MARK: -Private
    private func request(from rmRequest: RMRequest) -> URLRequest? {
        guard let url = rmRequest.url else {return nil}
        
        var request = URLRequest(url: url)
        request.httpMethod = rmRequest.httpMethod
        return request
    }
}
