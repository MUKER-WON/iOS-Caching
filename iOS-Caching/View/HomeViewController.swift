//
//  HomeViewController.swift
//  iOS-Caching
//
//  Created by Muker on 5/26/24.
//

import UIKit

final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Int, Photo>!
    
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        var layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(
            width: view.frame.width / 3 - 10,
            height: view.frame.width / 3 - 10
        )
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        var view = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: collectionViewFlowLayout
        )
        view.register(
            PhotoCell.self,
            forCellWithReuseIdentifier: PhotoCell.reuseIdentifier
        )
        view.backgroundColor = .white
        return view
    }()
    
    init(
        viewModel: HomeViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionViewDataSource()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification, 
            object: nil
        )
    }
    
    @objc func appWillEnterForeground() {
        viewModel.fetchPhotos()
    }
    
    private func configureUI() {
        [collectionView]
            .forEach {
                view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
        
        NSLayoutConstraint.activate([
                    collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                    collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
    }
    
    private func configureCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Photo>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, photo in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PhotoCell.reuseIdentifier,
                    for: indexPath
                ) as! PhotoCell
                cell.configure(
                    with: photo,
                    networkService: self.viewModel.networkService
                )
                return cell
            }
        )
    }
    
    private func bind() {
        viewModel.photosDidChange = { [weak self] photos in
            self?.updateSnapshot(with: photos)
        }
    }
    
    private func updateSnapshot(with photos: [Photo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Photo>()
        snapshot.appendSections([0])
        snapshot.appendItems(photos)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
