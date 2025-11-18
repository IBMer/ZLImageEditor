//
//  AdjustmentPanelView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Panel for adjusting image properties
struct AdjustmentPanelView: View {
    // MARK: - Properties

    @Bindable var viewModel: AdjustViewModel
    @State private var selectedTool: AdjustmentTool = .brightness

    private let configuration = EditorConfiguration.shared

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Tool selector
            AdjustToolPickerView(selectedTool: $selectedTool)

            // Slider for selected tool
            adjustmentSlider

            // Reset button
            Button(action: viewModel.reset) {
                Text("Reset")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
            }
            .disabled(viewModel.adjustStatus.allValueIsZero)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var adjustmentSlider: some View {
        switch selectedTool {
        case .brightness:
            AdjustmentSlider(
                value: $viewModel.brightness,
                range: configuration.brightnessRange,
                label: "Brightness",
                icon: "sun.max"
            )
        case .contrast:
            AdjustmentSlider(
                value: $viewModel.contrast,
                range: configuration.contrastRange,
                label: "Contrast",
                icon: "circle.lefthalf.filled"
            )
        case .saturation:
            AdjustmentSlider(
                value: $viewModel.saturation,
                range: configuration.saturationRange,
                label: "Saturation",
                icon: "drop.fill"
            )
        }
    }
}
