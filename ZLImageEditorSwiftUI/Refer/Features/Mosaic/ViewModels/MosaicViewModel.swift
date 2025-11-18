//
//  MosaicViewModel.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import UIKit
import Observation

/// ViewModel for mosaic functionality
@Observable
final class MosaicViewModel {
    // MARK: - State

    var paths: [MosaicPath] = []
    var mosaicImage: UIImage?
    var lineWidth: CGFloat

    // MARK: - Configuration

    private let configuration = EditorConfiguration.shared
    private let imageService = ImageProcessingService.shared

    // MARK: - Callbacks

    var onPathsChanged: (([MosaicPath]) -> Void)?

    // MARK: - Initialization

    init(originalImage: UIImage) {
        self.lineWidth = configuration.defaultMosaicLineWidth

        // Generate mosaic image asynchronously
        Task {
            let mosaic = await generateMosaicImage(from: originalImage)
            await MainActor.run {
                self.mosaicImage = mosaic
            }
        }
    }

    // MARK: - Methods

    func addPath(_ path: MosaicPath) {
        paths.append(path)
        onPathsChanged?(paths)
    }

    func clearAllPaths() {
        paths.removeAll()
        onPathsChanged?(paths)
    }

    func createPath(startPoint: CGPoint, ratio: CGFloat) -> MosaicPath {
        MosaicPath(
            pathWidth: lineWidth,
            ratio: ratio,
            startPoint: startPoint
        )
    }

    // MARK: - Private

    private func generateMosaicImage(from image: UIImage) async -> UIImage? {
        let scale = 8 * image.width / UIScreen.main.bounds.width
        return await imageService.applyPixelate(to: image, scale: scale)
    }
}
