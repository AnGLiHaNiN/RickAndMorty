//
//  CharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by Михаил on 18.04.2023.
//

import Foundation
import UIKit


protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
    func didLoadMoreChatacters(with newIndexPaths: [IndexPath])
    
    func didSelectCharacter(_ character: RMCharacter)
}


/// Viewmodel to handle character list view logic
final class RMCharacterListViewViewModel: NSObject {
    
    public weak var delegate: RMCharacterListViewViewModelDelegate?
    
    private var isLoadingMoreCharacters = false
    
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    chracterName: character.name,
                    characterStatus: character.status,
                    characterImageUrl: URL(string: character.image))
                if !cellViewModels.contains(viewModel){
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    private var apiInfo: RMGetAllCherectersResponse.Info? = nil
    
    /// Fetch initial set of chracters (20)
    public func fetchCharacters(){
        RMService.shared.execute(
            .listCharactersRequest,
            expecting: RMGetAllCherectersResponse.self,
            complition: { [weak self] result in
                switch result {
                case .success(let responceModel):
                    let results = responceModel.results
                    let info = responceModel.info
                    self?.characters = results
                    self?.apiInfo = info
                    DispatchQueue.main.async {
                        self?.delegate?.didLoadInitialCharacters()
                    }
                case .failure(let error):
                    print(String(describing: error))
                }
            })
    }
    
    
    /// Paginate if additional chracters are needed
    public func fetchAdditionalCharacters(url: URL){
        guard !isLoadingMoreCharacters else {
            return
        }
        
        isLoadingMoreCharacters = true
        guard let request = RMRequest(url: url) else {
            isLoadingMoreCharacters = false
            return
        }
        
        
        RMService.shared.execute(request,
                                 expecting: RMGetAllCherectersResponse.self) { [weak self] result in
            switch result {
            case .success(let responceModel):
                guard let stirongSelf = self else {
                    return
                }
                let moreResults = responceModel.results
                let info = responceModel.info
                stirongSelf.apiInfo = info
                
                print("More results count: \(moreResults.count)")
                
                let originalCount = stirongSelf.characters.count
                let newCount = moreResults.count
                let total = originalCount + newCount
                let startingIndex = total - newCount
                print("\(newCount)")
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap {
                    return IndexPath(row: $0, section: 0)
                }
                
                stirongSelf.characters.append(contentsOf: moreResults)
                DispatchQueue.main.async {
                    stirongSelf.delegate?.didLoadMoreChatacters(
                        with: indexPathsToAdd
                    )
                    stirongSelf.isLoadingMoreCharacters = false
                }
                    
            case .failure(let failure):
                print(String(describing: failure))
                self?.isLoadingMoreCharacters = false
            }
        }
    }
    
    public var shouldShowLoadMoreIndicator: Bool {
        return apiInfo?.next != nil
    }
}

//MARK: - CollectionView

extension RMCharacterListViewViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print(cellViewModels.map{$0.chracterName})
        return cellViewModels.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RMChatacterCollectionViewCell.cellIdentifier,
            for: indexPath) as? RMChatacterCollectionViewCell else {
                fatalError("Unsupported cell")
        }
        
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        guard shouldShowLoadMoreIndicator else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionFooter, let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier,
            for: indexPath
        ) as? RMFooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        
        footer.startAnimating()
        return footer
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 30) / 2
         return CGSize(width: width, height: width * 1.5 )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        delegate?.didSelectCharacter(character)
        
    }
}


// MARK: - ScrollView

extension RMCharacterListViewViewModel: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator,
              !isLoadingMoreCharacters,
              !cellViewModels.isEmpty,
              let nextUrlString = apiInfo?.next,
              let url = URL(string: nextUrlString) else {
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            
            let offset = scrollView.contentOffset .y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollVeiwFixedHeight = scrollView.frame.size.height
            
            if offset > (totalContentHeight - totalScrollVeiwFixedHeight - 120){
                self?.fetchAdditionalCharacters(url: url)
            }
            t.invalidate()
        }
    }
}
