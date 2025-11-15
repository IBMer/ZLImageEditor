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
        self.originalImage = originalImage.fixOrientation()
        self.currentImage = self.originalImage
    }

    // MARK: - Tool Selection

    func selectTool(_ tool: EditorTool?) {
        selectedTool = tool
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
        canUndo = await undoRedoManager.canUndo
        canRedo = await undoRedoManager.canRedo
    }

    private func applyUndoAction(_ action: EditAction) async {
        // Implementation will vary based on action type
        // For now, this is a placeholder
    }

    private func applyRedoAction(_ action: EditAction) async {
        // Implementation will vary based on action type
        // For now, this is a placeholder
    }

    // MARK: - Actions

    func cancel() {
        onCancel?()
    }

    func done() {
        Task {
            isProcessing = true
            let finalImage = await buildFinalImage()
            isProcessing = false
            onComplete?(finalImage)
        }
    }

    // MARK: - Image Building

    private func buildFinalImage() async -> UIImage {
        // For now, return current image
        // This will be implemented with full composite logic later
        currentImage
    }
}
