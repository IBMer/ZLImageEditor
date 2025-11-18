//
//  ClipViewModel.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI
import Observation

/// ViewModel for image clipping
@Observable
final class ClipViewModel {
    // MARK: - State

    var originalImage: UIImage
    var clipStatus: ClipStatus
    var selectedRatio: ClipRatio?
    var angle: Angle = .zero
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero

    // MARK: - Services

    private let imageService = ImageProcessingService.shared

    // MARK: - Callbacks

    var onClipChanged: ((ClipStatus) -> Void)?

    // MARK: - Initialization

    init(originalImage: UIImage, initialStatus: ClipStatus? = nil) {
        self.originalImage = originalImage

        if let status = initialStatus {
            self.clipStatus = status
            self.angle = Angle(radians: Double(status.angle))
            self.selectedRatio = status.ratio
        } else {
            let imageSize = originalImage.size
            self.clipStatus = ClipStatus(
                editRect: CGRect(origin: .zero, size: imageSize),
                angle: 0,
                ratio: nil
            )
        }
    }

    // MARK: - Methods

    func selectRatio(_ ratio: ClipRatio?) {
        selectedRatio = ratio
        updateClipRect()
    }

    func rotate90Degrees() {
        let currentAngle = angle.radians
        angle = Angle(radians: currentAngle - .pi / 2)
        updateClipStatus()
    }

    func reset() {
        angle = .zero
        scale = 1.0
        offset = .zero
        selectedRatio = nil
        clipStatus = ClipStatus(
            editRect: CGRect(origin: .zero, size: originalImage.size),
            angle: 0,
            ratio: nil
        )
        onClipChanged?(clipStatus)
    }

    func applyClip() async -> UIImage? {
        await imageService.clipImage(
            originalImage,
            angle: CGFloat(angle.radians),
            editRect: clipStatus.editRect,
            isCircle: selectedRatio?.isCircle ?? false
        )
    }

    // MARK: - Private

    private func updateClipRect() {
        // Simplified clip rect calculation
        // In a real implementation, this would calculate the proper rect
        // based on the selected ratio and current image size
        var newRect = CGRect(origin: .zero, size: originalImage.size)

        if let ratio = selectedRatio, ratio.whRatio > 0 {
            let imageSize = originalImage.size
            let targetRatio = ratio.whRatio

            if imageSize.width / imageSize.height > targetRatio {
                // Image is wider
                let newWidth = imageSize.height * targetRatio
                newRect = CGRect(
                    x: (imageSize.width - newWidth) / 2,
                    y: 0,
                    width: newWidth,
                    height: imageSize.height
                )
            } else {
                // Image is taller
                let newHeight = imageSize.width / targetRatio
                newRect = CGRect(
                    x: 0,
                    y: (imageSize.height - newHeight) / 2,
                    width: imageSize.width,
                    height: newHeight
                )
            }
        }

        clipStatus = ClipStatus(
            editRect: newRect,
            angle: CGFloat(angle.radians),
            ratio: selectedRatio
        )
        onClipChanged?(clipStatus)
    }

    private func updateClipStatus() {
        clipStatus = ClipStatus(
            editRect: clipStatus.editRect,
            angle: CGFloat(angle.radians),
            ratio: selectedRatio
        )
        onClipChanged?(clipStatus)
    }
}
