//
//  RMChatacterCollectionViewCell.swift
//  RickAndMorty
//
//  Created by Михаил on 18.04.2023.
//

import UIKit
import Foundation



///  Single cell for chatacter
final class RMChatacterCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "RMChatacterCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        [imageView, nameLabel, statusLabel].forEach {contentView.addSubview($0)}
        addConstraints()
        setUpLayer()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    
    private func setUpLayer(){
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor.label.cgColor
        contentView.layer.cornerRadius = 4
        contentView.layer.shadowOffset = CGSize(width: -4, height: 4)
        contentView.layer.shadowOpacity = 0.3
    }
    
    private func addConstraints(){
        NSLayoutConstraint.activate([
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  7),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7),
            statusLabel.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.bottomAnchor.constraint(equalTo: statusLabel.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  7),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -7),
            nameLabel.heightAnchor.constraint(equalToConstant: 30),
            
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor)
        ])
     }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setUpLayer()
    }
    
    
    override func prepareForReuse() {
        imageView.image = nil
        nameLabel.text = nil
        statusLabel.text = nil
        super.prepareForReuse()
    }
    
    public func configure(with viewModel: RMCharacterCollectionViewCellViewModel){
        statusLabel.text = viewModel.characterStatusText
        nameLabel.text = viewModel.characterName
        viewModel.fetchImage { [weak self] result in
            
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(data: data)
                }
            case .failure(let error):
                print(String(describing: error))
                break
            }
            
        }
    }
}
