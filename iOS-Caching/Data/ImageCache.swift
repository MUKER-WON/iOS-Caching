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
            let cacheDirectory = try fileManager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            diskCacheDirectory = cacheDirectory.appending(
                path: "ImageCache"
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
            memoryCache.setObject(discardableImage, forKey: key as NSString)
        }
        if policy == .disk || policy == .memoryAndDisk {
            let fileURL = diskCacheDirectory.appending(path: key)
            if let data = image.jpegData(compressionQuality: 1.0) {
                try? data.write(to: fileURL)
            }
        }
    }
    
    func image(
        forKey key: String,
        policy: CachePolicy
    ) -> UIImage? {
        if policy == .memory || policy == .memoryAndDisk {
            if let discardableImage = memoryCache.object(forKey: key as NSString) {
                if discardableImage.beginContentAccess() {
                    return discardableImage.image
                } else {
                    // 이미지가 더 이상 사용 가능하지 않은 상태인 경우
                    memoryCache.removeObject(forKey: key as NSString)
                }
            }
        }
        if policy == .disk || policy == .memoryAndDisk {
            let fileURL = diskCacheDirectory.appending(path: key)
            if let data = try? Data(contentsOf: fileURL),
               let image = UIImage(data: data) {
                return image
            }
        }
        return nil
    }
    
    func removeImage(forKey key: String, policy: CachePolicy) {
        if policy == .memory || policy == .memoryAndDisk {
            memoryCache.removeObject(forKey: key as NSString)
        }
        
        if policy == .disk || policy == .memoryAndDisk {
            let fileURL = diskCacheDirectory.appending(path: key)
            try? fileManager.removeItem(at: fileURL)
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


