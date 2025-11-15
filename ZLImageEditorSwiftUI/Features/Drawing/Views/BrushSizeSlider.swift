//
//  BrushSizeSlider.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Slider for adjusting brush size
struct BrushSizeSlider: View {
    // MARK: - Properties

    @Binding var size: CGFloat
    let range: ClosedRange<CGFloat>

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Brush Size")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                Text(String(format: "%.0f", size))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                // Min indicator
                Circle()
                    .fill(Color.primary)
                    .frame(width: 4, height: 4)

                // Slider
                Slider(value: $size, in: range)
                    .tint(.blue)

                // Max indicator
                Circle()
                    .fill(Color.primary)
                    .frame(width: 16, height: 16)
            }
        }
    }
}
