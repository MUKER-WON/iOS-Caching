//
//  HomeViewModel.swift
//  iOS-Caching
//
//  Created by Muker on 5/26/24.
//

import UIKit

final class HomeViewModel {
    let networkService: NetworkService
    
    var photosDidChange: (([Photo]) -> Void)?
    
    private var photos: [Photo] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.photosDidChange?(self?.photos ?? [])
            }
        }
    }
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchPhotos() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.thecatapi.com"
        components.path = "/v1/images/search"
        components.queryItems = .init(
            arrayLiteral: .init(name: "api_key", value: ConfigKey.apiKey),
                .init(name: "limit", value: "30")
        )
        guard let url = components.url else { return }
        networkService.fetch(url: url) { [weak self]
            (result: Result<[Photo], Error>) in
            switch result {
            case .success(let photos):
                self?.photos = photos
            case .failure(let error):
                print("\(error)")
            }
        }
    }
    
}
