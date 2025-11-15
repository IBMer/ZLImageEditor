//
//  AspectRatioPickerView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Horizontal picker for aspect ratios
struct AspectRatioPickerView: View {
    // MARK: - Properties

    @Bindable var viewModel: ClipViewModel
    private let configuration = EditorConfiguration.shared

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            // Ratio picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(configuration.clipRatios) { ratio in
                        RatioButton(
                            ratio: ratio,
                            isSelected: viewModel.selectedRatio == ratio,
                            action: { viewModel.selectRatio(ratio) }
                        )
                    }
                }
                .padding(.horizontal)
            }

            // Action buttons
            HStack(spacing: 16) {
                // Rotate button
                Button(action: viewModel.rotate90Degrees) {
                    Label("Rotate", systemImage: "rotate.right")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }

                // Reset button
                Button(action: viewModel.reset) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Ratio Button

private struct RatioButton: View {
    let ratio: ClipRatio
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if ratio.isCircle {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.white, lineWidth: 2)
                        .frame(width: 30, height: 30)
                } else {
                    RatioIcon(ratio: ratio.whRatio, isSelected: isSelected)
                }

                Text(ratio.title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .white)
            }
            .frame(width: 60)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ratio Icon

private struct RatioIcon: View {
    let ratio: CGFloat
    let isSelected: Bool

    var body: some View {
        ZStack {
            let width: CGFloat = ratio > 1 ? 30 : 20 * ratio
            let height: CGFloat = ratio > 1 ? 30 / ratio : 20

            Rectangle()
                .stroke(isSelected ? Color.blue : Color.white, lineWidth: 2)
                .frame(width: width, height: height)
        }
        .frame(width: 30, height: 30)
    }
}
