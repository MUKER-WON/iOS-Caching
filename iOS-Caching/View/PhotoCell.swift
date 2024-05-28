//
//  PhotoCell.swift
//  iOS-Caching
//
//  Created by Muker on 5/26/24.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    static let reuseIdentifier = "PhotoCell"
    
    let imageView: UIImageView = {
        var view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        [imageView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(
        with photo: Photo,
        networkService: NetworkService
    ) {
        loadImage(
            from: photo.url,
            networkService: networkService
        )
    }
    
    private func loadImage(
        from urlString: String,
        networkService: NetworkService
    ) {
        guard let url = URL(string: urlString) else { return }
        networkService.downloadImage(from: url) { [weak self] image in
            guard let self,
                  let image = image
            else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}
