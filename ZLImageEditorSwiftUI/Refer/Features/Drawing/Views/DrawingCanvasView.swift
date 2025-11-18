//
//  DrawingCanvasView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Canvas view for drawing
struct DrawingCanvasView: View {
    // MARK: - Properties

    @Bindable var viewModel: DrawingViewModel
    @State private var currentPath: DrawPath?
    @State private var currentPoints: [CGPoint] = []

    let canvasSize: CGSize
    let ratio: CGFloat

    // MARK: - Body

    var body: some View {
        Canvas { context, size in
            // Render completed paths
            for path in viewModel.paths {
                renderPath(path, in: context)
            }

            // Render current path being drawn
            if let current = currentPath {
                renderPath(current, in: context)
            }
        }
        .gesture(drawGesture)
        .background(Color.clear)
    }

    // MARK: - Gestures

    private var drawGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let point = value.location

                if currentPath == nil {
                    // Start new path
                    let path = viewModel.createPath(startPoint: point, ratio: ratio)
                    path.willDelete = viewModel.isEraserMode
                    currentPath = path
                    currentPoints = [point]
                } else {
                    // Add point to current path
                    currentPath?.addLine(to: point)
                    currentPoints.append(point)
                }
            }
            .onEnded { _ in
                // Finish path
                if let path = currentPath {
                    viewModel.addPath(path)
                }
                currentPath = nil
                currentPoints = []
            }
    }

    // MARK: - Rendering

    private func renderPath(_ path: DrawPath, in context: GraphicsContext) {
        var graphicsContext = context

        // Set color
        if path.willDelete {
            graphicsContext.stroke(
                Path(path.path.cgPath),
                with: .color(.white),
                lineWidth: path.path.lineWidth
            )
        }

        graphicsContext.stroke(
            Path(path.path.cgPath),
            with: .color(Color(path.pathColor)),
            lineWidth: path.path.lineWidth
        )
    }
}
