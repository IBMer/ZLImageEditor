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
    @State private var showTextInput = false
    @State private var textInput = ""
    @State private var textColor: Color = .white

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
                canvasView

                // Bottom toolbar
                BottomToolbarView(
                    selectedTool: $viewModel.selectedTool
                )
            }

            // Tool panels (overlay)
            toolPanelOverlay

            // Processing overlay
            if viewModel.isProcessing {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
            }

            // Text input sheet
            if showTextInput {
                textInputSheet
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var canvasView: some View {
        GeometryReader { geometry in
            ZStack {
                // Base image
                Image(uiImage: viewModel.currentImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                // Drawing canvas
                if viewModel.selectedTool == .draw {
                    DrawingCanvasView(
                        viewModel: viewModel.drawingVM,
                        canvasSize: geometry.size,
                        ratio: 1.0
                    )
                }

                // Mosaic canvas
                if viewModel.selectedTool == .mosaic {
                    MosaicCanvasView(
                        viewModel: viewModel.mosaicVM,
                        canvasSize: geometry.size,
                        ratio: 1.0
                    )
                }

                // Stickers
                StickerContainerView(viewModel: viewModel.stickerVM)
            }
        }
    }

    @ViewBuilder
    private var toolPanelOverlay: some View {
        VStack {
            Spacer()

            if let tool = viewModel.selectedTool {
                switch tool {
                case .filter:
                    FilterPickerView(viewModel: viewModel.filterVM)
                        .transition(.move(edge: .bottom))

                case .draw:
                    DrawingPanelView(viewModel: viewModel.drawingVM)
                        .transition(.move(edge: .bottom))

                case .adjust:
                    AdjustmentPanelView(viewModel: viewModel.adjustVM)
                        .transition(.move(edge: .bottom))

                case .mosaic:
                    MosaicPanelView(viewModel: viewModel.mosaicVM)
                        .transition(.move(edge: .bottom))

                case .clip:
                    AspectRatioPickerView(viewModel: viewModel.clipVM)
                        .transition(.move(edge: .bottom))

                case .textSticker:
                    textStickerButton
                        .transition(.move(edge: .bottom))

                case .imageSticker:
                    EmptyView()
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedTool)
    }

    private var textStickerButton: some View {
        Button {
            showTextInput = true
        } label: {
            Label("Add Text", systemImage: "plus.circle.fill")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private var textInputSheet: some View {
        TextInputView(
            text: $textInput,
            selectedColor: $textColor,
            onDone: {
                viewModel.stickerVM.addTextSticker(text: textInput, color: textColor)
                textInput = ""
                showTextInput = false
            },
            onCancel: {
                textInput = ""
                showTextInput = false
            }
        )
        .transition(.move(edge: .bottom))
    }
}
