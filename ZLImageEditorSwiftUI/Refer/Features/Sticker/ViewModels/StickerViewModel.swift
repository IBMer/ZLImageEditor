//
//  StickerViewModel.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI
import Observation

/// ViewModel for sticker management
@Observable
final class StickerViewModel {
    // MARK: - State

    var stickers: [StickerModel] = []
    var selectedStickerId: UUID?

    // MARK: - Configuration

    private let configuration = EditorConfiguration.shared

    // MARK: - Callbacks

    var onStickersChanged: (([StickerModel]) -> Void)?

    // MARK: - Methods

    func addTextSticker(text: String, color: Color = .white) {
        let sticker = StickerModel(
            type: .text(
                text: text,
                color: color,
                font: configuration.defaultTextFont
            ),
            position: .zero,
            scale: 1.0,
            rotation: .zero
        )
        stickers.append(sticker)
        selectedStickerId = sticker.id
        onStickersChanged?(stickers)
    }

    func addImageSticker(image: UIImage) {
        let sticker = StickerModel(
            type: .image(image: image),
            position: .zero,
            scale: 1.0,
            rotation: .zero
        )
        stickers.append(sticker)
        selectedStickerId = sticker.id
        onStickersChanged?(stickers)
    }

    func updateSticker(id: UUID, position: CGPoint? = nil, scale: CGFloat? = nil, rotation: Angle? = nil) {
        guard let index = stickers.firstIndex(where: { $0.id == id }) else { return }

        var sticker = stickers[index]
        if let position { sticker.position = position }
        if let scale { sticker.scale = scale }
        if let rotation { sticker.rotation = rotation }

        stickers[index] = sticker
        onStickersChanged?(stickers)
    }

    func deleteSticker(id: UUID) {
        stickers.removeAll { $0.id == id }
        if selectedStickerId == id {
            selectedStickerId = nil
        }
        onStickersChanged?(stickers)
    }

    func selectSticker(id: UUID) {
        selectedStickerId = id
    }

    func deselectAll() {
        selectedStickerId = nil
    }
}

// MARK: - Sticker Model

struct StickerModel: Identifiable {
    let id = UUID()
    let type: StickerType
    var position: CGPoint
    var scale: CGFloat
    var rotation: Angle

    enum StickerType {
        case text(text: String, color: Color, font: UIFont)
        case image(image: UIImage)
    }
}
