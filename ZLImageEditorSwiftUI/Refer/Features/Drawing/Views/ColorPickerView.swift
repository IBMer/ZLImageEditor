//
//  ColorPickerView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Horizontal color picker
struct ColorPickerView: View {
    // MARK: - Properties

    @Binding var selectedColor: Color
    let colors: [Color]

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                    ColorCircleButton(
                        color: color,
                        isSelected: color == selectedColor,
                        action: { selectedColor = color }
                    )
                }
            }
        }
    }
}

// MARK: - Color Circle Button

private struct ColorCircleButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: Constants.colorPickerItemSize, height: Constants.colorPickerItemSize)
                .overlay {
                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .padding(2)
                    }
                }
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}
