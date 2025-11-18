//
//  DrawPathRenderer.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import UIKit

/// Service for rendering draw paths
final class DrawPathRenderer {
    // MARK: - Singleton

    static let shared = DrawPathRenderer()

    private init() {}

    // MARK: - Constants

    private let maxDrawLineImageWidth: CGFloat = 600

    // MARK: - Rendering

    func render(paths: [DrawPath], on image: UIImage) -> UIImage {
        guard !paths.isEmpty else { return image }

        let size = image.size
        var scale: CGFloat = 1

        // Optimize for large images
        if size.width > maxDrawLineImageWidth {
            scale = maxDrawLineImageWidth / size.width
        }

        let drawSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: drawSize)
        return renderer.image { _ in
            for path in paths {
                path.drawPath()
            }
        }
    }

    func render(paths: [DrawPath], size: CGSize) -> UIImage? {
        guard !paths.isEmpty else { return nil }

        var scale: CGFloat = 1
        if size.width > maxDrawLineImageWidth {
            scale = maxDrawLineImageWidth / size.width
        }

        let drawSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: drawSize)
        return renderer.image { _ in
            for path in paths {
                path.drawPath()
            }
        }
    }
}
