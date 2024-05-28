//
//  ImageCache.swift
//  iOS-Caching
//
//  Created by Muker on 5/27/24.
//

import UIKit

final class ImageCache {
    private let memoryCache = NSCache<NSString, DiscardableImage>()
    private let fileManager = FileManager.default
    private let diskCacheDirectory: URL
    
    init() {
        do {
            let cacheDirectory = fileManager.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first!
            // cacheDirectory경로에 ImageCache폴더 생성
            diskCacheDirectory = cacheDirectory.appendingPathComponent(
                "ImageCache"
            )
            if !fileManager.fileExists(atPath: diskCacheDirectory.path) {
                try fileManager.createDirectory(
                    atPath: diskCacheDirectory.path,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }
        } catch {
            fatalError("cache directory 초기화 실패: \(error)")
        }
    }
    
    func setImage(
        _ image: UIImage,
        forKey key: String,
        policy: CachePolicy
    ) {
        let discardableImage = DiscardableImage(image: image)
        if policy == .memory || policy == .memoryAndDisk {
            // cache의 key값에 지정된 이미지를 저장
            memoryCache.setObject(discardableImage, forKey: key as NSString)
        }
        if policy == .disk || policy == .memoryAndDisk {
            let fileURL = diskCacheDirectory.appendingPathComponent(key)
            if let data = image.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: fileURL)
                } catch {
                    print("이미지 디스크캐시 저장 실패: \(error)")
                }
            }
        }
    }
    
    func getImage(
        forKey key: String,
        policy: CachePolicy
    ) -> UIImage? {
        // 메모리에 이미지 있는지 확인
        switch policy {
        case .memory:
            if let discardableImage = memoryCache.object(forKey: key as NSString) {
                if discardableImage.beginContentAccess() {
                    // accessCount를 +1 하게 된다.
                    return discardableImage.image
                } else {
                    // 이미지가 더 이상 사용 가능하지 않은 상태인 경우
                    memoryCache.removeObject(forKey: key as NSString)
                }
            }
            fallthrough
        case .disk:
            let fileURL = diskCacheDirectory.appending(path: key)
            if let data = try? Data(contentsOf: fileURL),
               let image = UIImage(data: data) {
                return image
            }
            fallthrough
        case .memoryAndDisk:
            return nil
        }
    }
    
    func removeImage(forKey key: String, policy: CachePolicy) {
        switch policy {
        case .memory:
            memoryCache.removeObject(forKey: key as NSString)
        case .disk:
            let fileURL = diskCacheDirectory.appending(path: key)
            try? fileManager.removeItem(at: fileURL)
        case .memoryAndDisk:
            break
        }
    }
}

// MARK: - Enum

enum CachePolicy {
    case memory
    case disk
    case memoryAndDisk
}

// MARK: - Extention

// MARK: - Protocol


