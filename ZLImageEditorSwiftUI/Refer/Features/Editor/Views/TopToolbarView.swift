//
//  TopToolbarView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Top toolbar with cancel, undo, redo, and done buttons
struct TopToolbarView: View {
    // MARK: - Properties

    let onCancel: () -> Void
    let onUndo: () -> Void
    let onRedo: () -> Void
    let onDone: () -> Void
    let canUndo: Bool
    let canRedo: Bool

    // MARK: - Body

    var body: some View {
        HStack {
            // Cancel button
            Button(action: onCancel) {
                Text("Cancel")
                    .foregroundColor(.white)
            }

            Spacer()

            // Undo/Redo buttons
            HStack(spacing: 20) {
                Button(action: onUndo) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title3)
                        .foregroundColor(canUndo ? .white : .gray)
                }
                .disabled(!canUndo)

                Button(action: onRedo) {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.title3)
                        .foregroundColor(canRedo ? .white : .gray)
                }
                .disabled(!canRedo)
            }

            Spacer()

            // Done button
            Button(action: onDone) {
                Text("Done")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
    }
}
