//
//  AdjustToolPickerView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Picker for selecting adjustment tool
struct AdjustToolPickerView: View {
    // MARK: - Properties

    @Binding var selectedTool: AdjustmentTool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            ForEach(AdjustmentTool.allCases) { tool in
                ToolButton(
                    tool: tool,
                    isSelected: selectedTool == tool,
                    action: { selectedTool = tool }
                )
            }
        }
    }
}

// MARK: - Tool Button

private struct ToolButton: View {
    let tool: AdjustmentTool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.iconName)
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .primary)

                Text(tool.displayName)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
