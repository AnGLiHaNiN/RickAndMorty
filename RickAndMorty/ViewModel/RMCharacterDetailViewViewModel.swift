//
//  RMCharacterDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Михаил on 18.04.2023.
//

import Foundation


final class RMCharacterDetailViewViewModel {
    
    private let character: RMCharacter
    
    init(character: RMCharacter) {
        self.character = character
    }
    
    public var name: String {
        return character.name.uppercased()
    }
}
