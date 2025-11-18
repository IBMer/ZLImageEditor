//
//  MosaicCanvasView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Canvas view for mosaic drawing
struct MosaicCanvasView: View {
    // MARK: - Properties

    @Bindable var viewModel: MosaicViewModel
    @State private var currentPath: MosaicPath?

    let canvasSize: CGSize
    let ratio: CGFloat

    // MARK: - Body

    var body: some View {
        Canvas { context, size in
            guard let mosaicImage = viewModel.mosaicImage else { return }

            // Create clipping mask from paths
            var clipPath = Path()
            for path in viewModel.paths {
                clipPath.addPath(Path(path.path.cgPath))
            }

            // Add current path
            if let current = currentPath {
                clipPath.addPath(Path(current.path.cgPath))
            }

            // Apply mask and draw mosaic
            context.clip(to: clipPath)
            context.draw(
                Image(uiImage: mosaicImage),
                in: CGRect(origin: .zero, size: size)
            )
        }
        .gesture(mosaicGesture)
        .background(Color.clear)
    }

    // MARK: - Gestures

    private var mosaicGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let point = value.location

                if currentPath == nil {
                    // Start new path
                    currentPath = viewModel.createPath(startPoint: point, ratio: ratio)
                } else {
                    // Add line to current path
                    currentPath?.addLine(to: point)
                }
            }
            .onEnded { _ in
                // Finish path
                if let path = currentPath {
                    viewModel.addPath(path)
                }
                currentPath = nil
            }
    }
}
