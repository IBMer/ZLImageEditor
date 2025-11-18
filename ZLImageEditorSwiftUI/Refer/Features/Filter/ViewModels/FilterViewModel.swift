//
//  FilterViewModel.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import UIKit
import Observation

/// ViewModel for filter selection and application
@Observable
final class FilterViewModel {
    // MARK: - State

    var originalImage: UIImage
    var selectedFilter: Filter = .normal
    var thumbnails: [FilterThumbnail] = []
    var isGeneratingThumbnails = false

    // MARK: - Services

    private let filterService = FilterService.shared

    // MARK: - Callbacks

    var onFilterChanged: ((Filter) -> Void)?

    // MARK: - Initialization

    init(originalImage: UIImage) {
        self.originalImage = originalImage
    }

    // MARK: - Methods

    func generateThumbnails() {
        guard thumbnails.isEmpty else { return }

        isGeneratingThumbnails = true

        Task {
            let filters = Filter.all
            let generatedThumbnails = await filterService.generateThumbnails(
                for: originalImage,
                filters: filters
            )

            await MainActor.run {
                self.thumbnails = generatedThumbnails
                self.isGeneratingThumbnails = false
            }
        }
    }

    func selectFilter(_ filter: Filter) {
        selectedFilter = filter
        onFilterChanged?(filter)
    }

    func applyFilter(to image: UIImage) async -> UIImage {
        await filterService.apply(selectedFilter, to: image)
    }
}
