//
//  AdjustmentSlider.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Slider for individual adjustment controls
struct AdjustmentSlider: View {
    // MARK: - Properties

    @Binding var value: Float
    let range: ClosedRange<Float>
    let label: String
    let icon: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.primary)

                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            // Slider
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Float($0) }
            ), in: Double(range.lowerBound)...Double(range.upperBound))
                .tint(.blue)
        }
    }
}
