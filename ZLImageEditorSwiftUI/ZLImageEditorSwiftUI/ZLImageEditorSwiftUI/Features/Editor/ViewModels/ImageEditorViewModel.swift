//
//  ImageEditorViewModel.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI
import Observation

/// Main view model for the image editor
@Observable
final class ImageEditorViewModel {
    // MARK: - State

    var originalImage: UIImage
    var currentImage: UIImage
    var selectedTool: EditorTool? = nil
    var canUndo = false
    var canRedo = false
    var isProcessing = false

    // MARK: - Sub-ViewModels

    var filterVM: FilterViewModel
    var drawingVM: DrawingViewModel
    var clipVM: ClipViewModel
    var adjustVM: AdjustViewModel
    var mosaicVM: MosaicViewModel
    var stickerVM: StickerViewModel

    // MARK: - Services

    private let imageService = ImageProcessingService.shared
    private let undoRedoManager = UndoRedoManager()

    // MARK: - Configuration

    private let configuration = EditorConfiguration.shared

    // MARK: - Callbacks

    var onComplete: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    // MARK: - Initialization

    init(originalImage: UIImage) {
        let fixedImage = originalImage.fixOrientation()
        self.originalImage = fixedImage
        self.currentImage = fixedImage

        // Initialize sub-ViewModels
        self.filterVM = FilterViewModel(originalImage: fixedImage)
        self.drawingVM = DrawingViewModel()
        self.clipVM = ClipViewModel(originalImage: fixedImage)
        self.adjustVM = AdjustViewModel(originalImage: fixedImage)
        self.mosaicVM = MosaicViewModel(originalImage: fixedImage)
        self.stickerVM = StickerViewModel()

        // Set up callbacks
        setupCallbacks()
    }

    // MARK: - Setup

    private func setupCallbacks() {
        filterVM.onFilterChanged = { [weak self] filter in
            Task { @MainActor in
                await self?.applyCurrentEdits()
            }
        }

        drawingVM.onPathsChanged = { [weak self] _ in
            Task { @MainActor in
                await self?.applyCurrentEdits()
            }
        }

        adjustVM.onAdjustmentChanged = { [weak self] _ in
            Task { @MainActor in
                await self?.applyCurrentEdits()
            }
        }

        mosaicVM.onPathsChanged = { [weak self] _ in
            Task { @MainActor in
                await self?.applyCurrentEdits()
            }
        }

        stickerVM.onStickersChanged = { [weak self] _ in
            // Stickers are rendered on top, no need to rebuild
        }

        clipVM.onClipChanged = { [weak self] _ in
            // Clip is applied at the end
        }
    }

    // MARK: - Tool Selection

    func selectTool(_ tool: EditorTool?) {
        selectedTool = tool
    }

    // MARK: - Apply Edits

    private func applyCurrentEdits() async {
        var result = originalImage

        // Apply filter
        if filterVM.selectedFilter.type != .normal {
            result = await filterVM.applyFilter(to: result)
        }

        // Apply adjustments
        if !adjustVM.adjustStatus.allValueIsZero {
            result = await adjustVM.applyAdjustments(to: result) ?? result
        }

        // Update current image
        await MainActor.run {
            currentImage = result
        }
    }

    // MARK: - Undo/Redo

    func undo() {
        Task {
            guard let action = await undoRedoManager.undo() else { return }
            await applyUndoAction(action)
            await updateUndoRedoState()
        }
    }

    func redo() {
        Task {
            guard let action = await undoRedoManager.redo() else { return }
            await applyRedoAction(action)
            await updateUndoRedoState()
        }
    }

    private func updateUndoRedoState() async {
        let canUndoValue = await undoRedoManager.canUndo
        let canRedoValue = await undoRedoManager.canRedo

        await MainActor.run {
            canUndo = canUndoValue
            canRedo = canRedoValue
        }
    }

    private func applyUndoAction(_ action: EditAction) async {
        // TODO: Implement undo logic for each action type
    }

    private func applyRedoAction(_ action: EditAction) async {
        // TODO: Implement redo logic for each action type
    }

    // MARK: - Actions

    func cancel() {
        onCancel?()
    }

    func done() {
        Task {
            await MainActor.run {
                isProcessing = true
            }

            let finalImage = await buildFinalImage()

            await MainActor.run {
                isProcessing = false
                onComplete?(finalImage)
            }
        }
    }

    // MARK: - Image Building

    private func buildFinalImage() async -> UIImage {
        var result = originalImage

        // 1. Apply clip if needed
        if let clippedImage = await clipVM.applyClip() {
            result = clippedImage
        }

        // 2. Apply filter
        if filterVM.selectedFilter.type != .normal {
            result = await filterVM.applyFilter(to: result)
        }

        // 3. Apply adjustments
        if !adjustVM.adjustStatus.allValueIsZero {
            result = await adjustVM.applyAdjustments(to: result) ?? result
        }

        // 4. Apply drawing
        if !drawingVM.paths.isEmpty {
            result = await Task.detached {
                self.drawingVM.renderDrawing(on: result)
            }.value
        }

        // 5. Apply mosaic
        if !mosaicVM.paths.isEmpty, let mosaicImage = mosaicVM.mosaicImage {
            result = await compositeMosaic(mosaicImage, paths: mosaicVM.paths, onto: result)
        }

        // 6. Render stickers on top
        if !stickerVM.stickers.isEmpty {
            result = await renderStickers(on: result)
        }

        return result
    }

    // MARK: - Private Helpers

    private func compositeMosaic(_ mosaicImage: UIImage, paths: [MosaicPath], onto background: UIImage) async -> UIImage {
        await Task.detached {
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
        }.value
    }

    private func renderStickers(on image: UIImage) async -> UIImage {
        await Task.detached {
            let renderer = UIGraphicsImageRenderer(size: image.size)
            return renderer.image { context in
                image.draw(at: .zero)

                for sticker in self.stickerVM.stickers {
                    context.cgContext.saveGState()

                    // Apply transform
                    let transform = CGAffineTransform.identity
                        .translatedBy(x: sticker.position.x, y: sticker.position.y)
                        .rotated(by: sticker.rotation.radians)
                        .scaledBy(x: sticker.scale, y: sticker.scale)

                    context.cgContext.concatenate(transform)

                    // Render sticker content
                    switch sticker.type {
                    case .text(let text, let color, let font):
                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: font,
                            .foregroundColor: color.toUIColor()
                        ]
                        let size = text.size(withAttributes: attributes)
                        text.draw(at: CGPoint(x: -size.width/2, y: -size.height/2), withAttributes: attributes)

                    case .image(let stickerImage):
                        let size = CGSize(width: 100, height: 100)
                        stickerImage.draw(in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
                    }

                    context.cgContext.restoreGState()
                }
            }
        }.value
    }
}
