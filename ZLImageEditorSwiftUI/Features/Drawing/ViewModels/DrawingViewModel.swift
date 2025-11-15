//
//  DrawingViewModel.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI
import Observation

/// ViewModel for drawing functionality
@Observable
final class DrawingViewModel {
    // MARK: - State

    var paths: [DrawPath] = []
    var currentColor: Color
    var brushSize: CGFloat
    var isEraserMode = false

    // MARK: - Configuration

    private let configuration = EditorConfiguration.shared
    private let pathRenderer = DrawPathRenderer.shared

    // MARK: - Callbacks

    var onPathsChanged: (([DrawPath]) -> Void)?

    // MARK: - Initialization

    init() {
        self.currentColor = configuration.defaultDrawColor
        self.brushSize = configuration.defaultBrushSize
    }

    // MARK: - Methods

    func addPath(_ path: DrawPath) {
        paths.append(path)
        onPathsChanged?(paths)
    }

    func removePath(at index: Int) {
        guard index < paths.count else { return }
        paths.remove(at: index)
        onPathsChanged?(paths)
    }

    func clearAllPaths() {
        paths.removeAll()
        onPathsChanged?(paths)
    }

    func toggleEraser() {
        isEraserMode.toggle()
    }

    func renderDrawing(on image: UIImage) -> UIImage {
        guard !paths.isEmpty else { return image }
        return pathRenderer.render(paths: paths, on: image)
    }

    func createPath(startPoint: CGPoint, ratio: CGFloat) -> DrawPath {
        DrawPath(
            pathColor: currentColor.toUIColor(),
            pathWidth: brushSize,
            defaultLinePath: 5.0,
            ratio: ratio,
            startPoint: startPoint
        )
    }
}
