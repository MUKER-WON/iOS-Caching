//
//  DicardableImage.swift
//  iOS-Caching
//
//  Created by Muker on 5/27/24.
//

import UIKit

final class DiscardableImage: NSObject, NSDiscardableContent {
    private(set) var image: UIImage?
    private var accessCount = 0
    
    init(image: UIImage) {
        self.image = image
        super.init()
    }
    /// 객체의 콘텐츠를 사용하기 시작할 때 호출
    /// 객체가 유효하면 true, 그렇지 않으면 false 반환
    func beginContentAccess() -> Bool {
        if image == nil {
            return false
        }
        accessCount += 1
        return true
    }
    /// 객체의 콘텐츠 사용을 끝낼 때 호출
    func endContentAccess() {
        if accessCount > 0 {
            accessCount -= 1
        }
    }
    /// 시스템이 메모리가 부족할 때 호출
    /// 객체는 필요에 따라 자신의 콘텐츠를 해제할 수 있음
    func discardContentIfPossible() {
        if accessCount == 0 {
            image = nil
        }
    }
    /// 해당 객체가 해제되었는지 확인
    func isContentDiscarded() -> Bool {
        return image == nil
    }
    
    
}
