//
//  StickerContainerView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Container for all stickers
struct StickerContainerView: View {
    // MARK: - Properties

    @Bindable var viewModel: StickerViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            ForEach(viewModel.stickers) { sticker in
                StickerView(
                    sticker: sticker,
                    isSelected: viewModel.selectedStickerId == sticker.id,
                    onTap: { viewModel.selectSticker(id: sticker.id) },
                    onTransformChange: { position, scale, rotation in
                        viewModel.updateSticker(
                            id: sticker.id,
                            position: position,
                            scale: scale,
                            rotation: rotation
                        )
                    },
                    onDelete: { viewModel.deleteSticker(id: sticker.id) }
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.deselectAll()
        }
    }
}
