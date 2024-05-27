//
//  Photo.swift
//  iOS-Caching
//
//  Created by Muker on 5/26/24.
//

import Foundation

struct Photo: Codable, Hashable {
    let id: String
    let url: String
    let width: Int
    let height: Int
}
