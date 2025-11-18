//
//  ClipEditorView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Full-screen clip editor view
struct ClipEditorView: View {
    // MARK: - Properties

    @Bindable var viewModel: ClipViewModel
    @State private var isDragging = false

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Image layer
                Image(uiImage: viewModel.originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .rotationEffect(viewModel.angle)

                // Clip overlay (darkened area outside clip rect)
                ClipOverlayView(clipRect: viewModel.clipStatus.editRect)

                // Grid lines
                ClipGridView(clipRect: viewModel.clipStatus.editRect)
            }
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        viewModel.scale = value.magnification
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        viewModel.offset = value.translation
                    }
            )
        }
    }
}
