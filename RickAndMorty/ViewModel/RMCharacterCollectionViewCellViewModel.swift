//
//  RMChatacterCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Михаил on 18.04.2023.
//

import Foundation


final class RMCharacterCollectionViewCellViewModel: Hashable, Equatable {
     
    public let characterName: String
    private let characterStatus: RMCharacterStatus
    private let characterImageUrl: URL?
    
    
    //MARK: -Init
    init(chracterName: String, characterStatus: RMCharacterStatus, characterImageUrl: URL?) {
        self.characterName = chracterName
        self.characterStatus = characterStatus
        self.characterImageUrl = characterImageUrl
    }
    
    
    public var characterStatusText: String {
        return "Status: \(characterStatus.text)"
    }
    
    public func fetchImage(complition: @escaping (Result<Data, Error>) -> Void){
        
        guard let url = characterImageUrl else {
            complition(.failure(URLError(.badURL)))
            return
        }
        RMImageLoader.shared.downloadImage(url, complition: complition)
    }
    
    // MARK: - Hashable
    static func == (lhs: RMCharacterCollectionViewCellViewModel, rhs: RMCharacterCollectionViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
//        return lhs.characterName == rhs.characterName &&
//        lhs.characterStatus == rhs.characterStatus &&
//        lhs.characterImageUrl == rhs.characterImageUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(characterName)
        hasher.combine(characterStatus)
        hasher.combine(characterImageUrl)
    }
}
