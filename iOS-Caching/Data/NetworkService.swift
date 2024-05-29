//
//  NetworkService.swift
//  iOS-Caching
//
//  Created by Muker on 5/26/24.
//

// NetworkService는 UIKit을 알고있지 않는 형태가 더 바람직합니다.
// Sample Project라 허용합니다.
import UIKit

final class NetworkService {
    private let imageCache: ImageCache
    
    init(imageCache: ImageCache) {
        self.imageCache = imageCache
    }
    
    func fetch<T: Decodable>(
        url: URL,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func downloadImage(
        from url: URL,
        completion: @escaping (UIImage?) -> Void
    ) {
        let cacheKey = url.path.components(separatedBy: "/").last!
        // 1. 메모리 캐시 확인
        if let cachedImage = imageCache.getImage(
            forKey: cacheKey,
            policy: .memory
        ) {
            completion(cachedImage)
            return
        }
        // 2. 디스크 캐시 확인
        if let cachedImage = imageCache.getImage(
            forKey: cacheKey,
            policy: .disk
        ) {
            imageCache.setImage(
                cachedImage,
                forKey: cacheKey,
                policy: .memory
            )
            completion(cachedImage)
            return
        }
        // 3. 네트워크에서 이미지 다운로드
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self,
                  let data,
                  let image = UIImage(data: data),
                  error == nil
            else {
                completion(nil)
                return
            }
            // 4. 메모리 및 디스크 캐시에 저장
            self.imageCache.setImage(
                image,
                forKey: cacheKey,
                policy: .memoryAndDisk
            )
            completion(image)
        }
        task.resume()
    }
}

enum NetworkError: LocalizedError {
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "NETWORK ERROR: 유효하지 않은 데이터"
        }
    }
}
