//
//  MosaicPanelView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Control panel for mosaic tools
struct MosaicPanelView: View {
    // MARK: - Properties

    @Bindable var viewModel: MosaicViewModel
    private let configuration = EditorConfiguration.shared

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Line width slider
            VStack(spacing: 8) {
                HStack {
                    Text("Brush Size")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(String(format: "%.0f", viewModel.lineWidth))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 8, height: 8)

                    Slider(
                        value: $viewModel.lineWidth,
                        in: configuration.minMosaicLineWidth...configuration.maxMosaicLineWidth
                    )
                    .tint(.blue)

                    Circle()
                        .fill(Color.primary)
                        .frame(width: 20, height: 20)
                }
            }

            // Clear button
            Button(action: viewModel.clearAllPaths) {
                Label("Clear All", systemImage: "trash")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
            }
            .disabled(viewModel.paths.isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
