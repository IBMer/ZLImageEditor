//
//  ImageProcessingService.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import UIKit
import CoreImage

/// Service for image processing operations
actor ImageProcessingService {
    // MARK: - Singleton

    static let shared = ImageProcessingService()

    private init() {}

    // MARK: - Mosaic

    func applyPixelate(to image: UIImage, scale: CGFloat) async -> UIImage? {
        await Task.detached {
            image.mosaicImage()
        }.value
    }

    // MARK: - Color Adjustments

    func applyColorControls(
        to image: UIImage,
        brightness: Float,
        contrast: Float,
        saturation: Float
    ) async -> UIImage? {
        await Task.detached {
            image.adjust(brightness: brightness, contrast: contrast, saturation: saturation)
        }.value
    }

    // MARK: - Blur

    func applyBlur(to image: UIImage, level: CGFloat) async -> UIImage? {
        await Task.detached {
            image.blurImage(level: level)
        }.value
    }

    // MARK: - Clipping

    func clipImage(_ image: UIImage, angle: CGFloat, editRect: CGRect, isCircle: Bool) async -> UIImage? {
        await Task.detached {
            image.clipImage(angle: angle, editRect: editRect, isCircle: isCircle)
        }.value
    }

    // MARK: - Rotation

    func rotate(_ image: UIImage, by degree: CGFloat) async -> UIImage? {
        await Task.detached {
            image.rotate(degree: degree)
        }.value
    }

    // MARK: - Resizing

    func resize(_ image: UIImage, to size: CGSize, useAccelerate: Bool = true) async -> UIImage? {
        await Task.detached {
            if useAccelerate {
                return image.resize_vI(size)
            } else {
                return image.resize(size)
            }
        }.value
    }

    // MARK: - Compression

    func compress(_ image: UIImage, toMaxSize maxSize: Int) async -> UIImage {
        await Task.detached {
            image.compress(to: maxSize)
        }.value
    }

    // MARK: - Orientation

    func fixOrientation(_ image: UIImage) async -> UIImage {
        await Task.detached {
            image.fixOrientation()
        }.value
    }

    // MARK: - Composite Drawing

    func renderDrawPaths(_ paths: [DrawPath], on image: UIImage) async -> UIImage {
        await Task.detached {
            guard !paths.isEmpty else { return image }

            let maxDrawLineImageWidth: CGFloat = 600
            let size = image.size
            var scale: CGFloat = 1

            if size.width > maxDrawLineImageWidth {
                scale = maxDrawLineImageWidth / size.width
            }

            let drawSize = CGSize(width: size.width * scale, height: size.height * scale)

            let renderer = UIGraphicsImageRenderer(size: drawSize)
            return renderer.image { context in
                // Draw paths
                for path in paths {
                    path.drawPath()
                }
            }
        }.value
    }

    // MARK: - Final Image Build

    func buildFinalImage(
        baseImage: UIImage,
        drawingImage: UIImage?,
        mosaicImage: UIImage?,
        mosaicPaths: [MosaicPath],
        filter: Filter?,
        adjustStatus: AdjustStatus?
    ) async -> UIImage {
        await Task.detached {
            var result = baseImage

            // Apply filter
            if let filter, filter.type != .normal {
                result = filter.apply(to: result)
            }

            // Apply adjustments
            if let adjustStatus, !adjustStatus.allValueIsZero {
                result = result.adjust(
                    brightness: adjustStatus.brightness,
                    contrast: adjustStatus.contrast,
                    saturation: adjustStatus.saturation
                ) ?? result
            }

            // Composite drawing
            if let drawingImage {
                result = await self.composite(drawingImage, onto: result)
            }

            // Composite mosaic
            if let mosaicImage, !mosaicPaths.isEmpty {
                result = await self.compositeMosaic(mosaicImage, paths: mosaicPaths, onto: result)
            }

            return result
        }.value
    }

    // MARK: - Private Helpers

    private func composite(_ foreground: UIImage, onto background: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: background.size)
        return renderer.image { _ in
            background.draw(at: .zero)
            foreground.draw(at: .zero, blendMode: .normal, alpha: 1.0)
        }
    }

    private func compositeMosaic(_ mosaicImage: UIImage, paths: [MosaicPath], onto background: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: background.size)
        return renderer.image { context in
            background.draw(at: .zero)

            // Create mask from paths
            let maskPath = UIBezierPath()
            for path in paths {
                maskPath.append(path.path)
            }

            // Clip to mask and draw mosaic
            context.cgContext.saveGState()
            maskPath.addClip()
            mosaicImage.draw(at: .zero)
            context.cgContext.restoreGState()
        }
    }
}
