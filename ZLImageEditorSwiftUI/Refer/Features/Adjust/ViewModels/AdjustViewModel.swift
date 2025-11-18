//
//  AdjustViewModel.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import UIKit
import Observation

/// ViewModel for image adjustments
@Observable
final class AdjustViewModel {
    // MARK: - State

    var originalImage: UIImage
    var adjustStatus: AdjustStatus
    var brightness: Float = 0
    var contrast: Float = 0
    var saturation: Float = 0

    // MARK: - Services

    private let imageService = ImageProcessingService.shared

    // MARK: - Callbacks

    var onAdjustmentChanged: ((AdjustStatus) -> Void)?

    // MARK: - Initialization

    init(originalImage: UIImage, initialStatus: AdjustStatus = AdjustStatus()) {
        self.originalImage = originalImage
        self.adjustStatus = initialStatus
        self.brightness = initialStatus.brightness
        self.contrast = initialStatus.contrast
        self.saturation = initialStatus.saturation
    }

    // MARK: - Methods

    func updateBrightness(_ value: Float) {
        brightness = value
        updateStatus()
    }

    func updateContrast(_ value: Float) {
        contrast = value
        updateStatus()
    }

    func updateSaturation(_ value: Float) {
        saturation = value
        updateStatus()
    }

    func reset() {
        brightness = 0
        contrast = 0
        saturation = 0
        updateStatus()
    }

    func applyAdjustments(to image: UIImage) async -> UIImage {
        guard !adjustStatus.allValueIsZero else { return image }

        return await imageService.applyColorControls(
            to: image,
            brightness: brightness,
            contrast: contrast,
            saturation: saturation
        ) ?? image
    }

    // MARK: - Private

    private func updateStatus() {
        adjustStatus = AdjustStatus(
            brightness: brightness,
            contrast: contrast,
            saturation: saturation
        )
        onAdjustmentChanged?(adjustStatus)
    }
}
