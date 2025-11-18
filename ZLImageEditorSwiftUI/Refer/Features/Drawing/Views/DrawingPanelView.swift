//
//  DrawingPanelView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Control panel for drawing tools
struct DrawingPanelView: View {
    // MARK: - Properties

    @Bindable var viewModel: DrawingViewModel
    private let configuration = EditorConfiguration.shared

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Color picker
            ColorPickerView(
                selectedColor: $viewModel.currentColor,
                colors: configuration.drawColors
            )

            // Brush size slider
            BrushSizeSlider(
                size: $viewModel.brushSize,
                range: configuration.minBrushSize...configuration.maxBrushSize
            )

            // Action buttons
            HStack(spacing: 20) {
                // Eraser toggle
                Button(action: viewModel.toggleEraser) {
                    Label(
                        viewModel.isEraserMode ? "Draw" : "Erase",
                        systemImage: viewModel.isEraserMode ? "pencil" : "eraser"
                    )
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(viewModel.isEraserMode ? Color.red : Color.blue)
                    .cornerRadius(8)
                }

                // Clear all button
                Button(action: viewModel.clearAllPaths) {
                    Label("Clear", systemImage: "trash")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
                .disabled(viewModel.paths.isEmpty)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
