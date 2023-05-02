//
//  RMGetAllCherectersResponse.swift
//  RickAndMorty
//
//  Created by Михаил on 18.04.2023.
//

import Foundation


struct RMGetAllCherectersResponse: Codable {
    struct Info: Codable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
    
    let info: Info
    let results: [RMCharacter]
}

