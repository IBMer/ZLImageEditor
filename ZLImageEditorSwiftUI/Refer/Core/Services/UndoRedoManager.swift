//
//  UndoRedoManager.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from ZLEditorManager.swift
//  Created by SwiftUI Rewrite
//

import Foundation

/// Thread-safe undo/redo manager using Actor
actor UndoRedoManager {
    // MARK: - Properties

    private var actions: [EditAction] = []
    private var redoActions: [EditAction] = []

    // MARK: - Public Interface

    var canUndo: Bool {
        !actions.isEmpty
    }

    var canRedo: Bool {
        !redoActions.isEmpty
    }

    var actionCount: Int {
        actions.count
    }

    // MARK: - Methods

    /// Record a new action
    func record(_ action: EditAction) {
        actions.append(action)
        redoActions.removeAll()
    }

    /// Undo the last action
    func undo() -> EditAction? {
        guard let action = actions.popLast() else {
            return nil
        }
        redoActions.append(action)
        return action
    }

    /// Redo the last undone action
    func redo() -> EditAction? {
        guard let action = redoActions.popLast() else {
            return nil
        }
        actions.append(action)
        return action
    }

    /// Clear all actions
    func reset() {
        actions.removeAll()
        redoActions.removeAll()
    }

    /// Get all actions (for debugging or state persistence)
    func getAllActions() -> [EditAction] {
        actions
    }

    /// Get all redo actions (for debugging)
    func getAllRedoActions() -> [EditAction] {
        redoActions
    }
}
