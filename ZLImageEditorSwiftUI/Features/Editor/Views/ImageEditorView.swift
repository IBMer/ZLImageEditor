//
//  ImageEditorView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Main image editor view
struct ImageEditorView: View {
    // MARK: - Properties

    @State private var viewModel: ImageEditorViewModel

    // MARK: - Initialization

    init(
        originalImage: UIImage,
        onComplete: @escaping (UIImage) -> Void,
        onCancel: @escaping () -> Void
    ) {
        let vm = ImageEditorViewModel(originalImage: originalImage)
        vm.onComplete = onComplete
        vm.onCancel = onCancel
        _viewModel = State(initialValue: vm)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top toolbar
                TopToolbarView(
                    onCancel: viewModel.cancel,
                    onUndo: viewModel.undo,
                    onRedo: viewModel.redo,
                    onDone: viewModel.done,
                    canUndo: viewModel.canUndo,
                    canRedo: viewModel.canRedo
                )

                // Canvas
                ImageCanvasView(image: viewModel.currentImage)

                // Bottom toolbar
                BottomToolbarView(
                    selectedTool: $viewModel.selectedTool
                )
            }

            // Processing overlay
            if viewModel.isProcessing {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
            }
        }
    }
}
