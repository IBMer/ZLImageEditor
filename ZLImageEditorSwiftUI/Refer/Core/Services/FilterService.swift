//
//  FilterService.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import UIKit

/// Service for filter operations
actor FilterService {
    // MARK: - Singleton

    static let shared = FilterService()

    private init() {}

    // MARK: - Filter Application

    func apply(_ filter: Filter, to image: UIImage) async -> UIImage {
        await Task.detached {
            filter.apply(to: image)
        }.value
    }

    // MARK: - Thumbnail Generation

    func generateThumbnails(for image: UIImage, filters: [Filter]) async -> [FilterThumbnail] {
        let thumbSize = CGSize(width: 200, height: 200)

        guard let resizedImage = await resize(image, to: thumbSize) else {
            return []
        }

        var thumbnails: [FilterThumbnail] = []

        for filter in filters {
            let filteredImage = await apply(filter, to: resizedImage)
            thumbnails.append(FilterThumbnail(filter: filter, image: filteredImage))
        }

        return thumbnails
    }

    // MARK: - Private Helpers

    private func resize(_ image: UIImage, to size: CGSize) async -> UIImage? {
        await Task.detached {
            image.resize_vI(size)
        }.value
    }
}

// MARK: - Filter Thumbnail Model

struct FilterThumbnail: Identifiable {
    let id = UUID()
    let filter: Filter
    let image: UIImage
}
