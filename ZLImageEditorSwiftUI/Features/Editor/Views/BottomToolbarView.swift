//
//  BottomToolbarView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Bottom toolbar for selecting editing tools
struct BottomToolbarView: View {
    // MARK: - Properties

    @Binding var selectedTool: EditorTool?
    private let configuration = EditorConfiguration.shared

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(configuration.tools) { tool in
                    ToolButton(
                        tool: tool,
                        isSelected: selectedTool == tool,
                        action: { toggleTool(tool) }
                    )
                }
            }
            .padding(.horizontal)
        }
        .frame(height: Constants.toolbarHeight)
        .background(Color.black.opacity(0.8))
    }

    // MARK: - Actions

    private func toggleTool(_ tool: EditorTool) {
        if selectedTool == tool {
            selectedTool = nil
        } else {
            selectedTool = tool
        }
    }
}

// MARK: - Tool Button

private struct ToolButton: View {
    let tool: EditorTool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.iconName)
                    .font(.system(size: Constants.toolIconSize))
                    .foregroundColor(isSelected ? .blue : .white)

                Text(tool.displayName)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .white)
            }
            .frame(width: 60)
        }
    }
}
