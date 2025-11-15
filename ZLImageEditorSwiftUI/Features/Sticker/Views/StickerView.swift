//
//  StickerView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Individual sticker view with gesture support
struct StickerView: View {
    // MARK: - Properties

    let sticker: StickerModel
    let isSelected: Bool
    let onTap: () -> Void
    let onTransformChange: (CGPoint, CGFloat, Angle) -> Void
    let onDelete: () -> Void

    @State private var currentPosition: CGPoint
    @State private var currentScale: CGFloat
    @State private var currentRotation: Angle

    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var magnifyAmount: CGFloat = 1.0
    @GestureState private var rotationAmount: Angle = .zero

    // MARK: - Initialization

    init(
        sticker: StickerModel,
        isSelected: Bool,
        onTap: @escaping () -> Void,
        onTransformChange: @escaping (CGPoint, CGFloat, Angle) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.sticker = sticker
        self.isSelected = isSelected
        self.onTap = onTap
        self.onTransformChange = onTransformChange
        self.onDelete = onDelete

        _currentPosition = State(initialValue: sticker.position)
        _currentScale = State(initialValue: sticker.scale)
        _currentRotation = State(initialValue: sticker.rotation)
    }

    // MARK: - Body

    var body: some View {
        content
            .position(
                x: currentPosition.x + dragOffset.width,
                y: currentPosition.y + dragOffset.height
            )
            .scaleEffect(currentScale * magnifyAmount)
            .rotationEffect(currentRotation + rotationAmount)
            .overlay {
                if isSelected {
                    stickerBorder
                }
            }
            .onTapGesture {
                onTap()
            }
            .gesture(combinedGesture)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var content: some View {
        switch sticker.type {
        case .text(let text, let color, let font):
            Text(text)
                .font(Font(font))
                .foregroundColor(color)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)

        case .image(let image):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        }
    }

    private var stickerBorder: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .foregroundColor(.blue)
            .padding(-8)
    }

    // MARK: - Gestures

    private var combinedGesture: some Gesture {
        SimultaneousGesture(
            dragGesture,
            SimultaneousGesture(
                magnifyGesture,
                rotateGesture
            )
        )
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                currentPosition = CGPoint(
                    x: currentPosition.x + value.translation.width,
                    y: currentPosition.y + value.translation.height
                )
                onTransformChange(currentPosition, currentScale, currentRotation)
            }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .updating($magnifyAmount) { value, state, _ in
                state = value.magnification
            }
            .onEnded { value in
                currentScale *= value.magnification
                currentScale = min(max(currentScale, Constants.minStickerScale), Constants.maxStickerScale)
                onTransformChange(currentPosition, currentScale, currentRotation)
            }
    }

    private var rotateGesture: some Gesture {
        RotateGesture()
            .updating($rotationAmount) { value, state, _ in
                state = value.rotation
            }
            .onEnded { value in
                currentRotation = Angle(radians: currentRotation.radians + value.rotation.radians)
                onTransformChange(currentPosition, currentScale, currentRotation)
            }
    }
}
