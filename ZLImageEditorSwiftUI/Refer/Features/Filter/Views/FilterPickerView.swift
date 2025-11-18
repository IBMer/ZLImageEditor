//
//  FilterPickerView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Horizontal scrollable filter picker
struct FilterPickerView: View {
    // MARK: - Properties

    @Bindable var viewModel: FilterViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isGeneratingThumbnails {
                loadingView
            } else {
                thumbnailList
            }
        }
        .frame(height: 140)
        .background(.ultraThinMaterial)
        .onAppear {
            viewModel.generateThumbnails()
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)

            Text("Generating Filters...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var thumbnailList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.thumbnails) { thumbnail in
                    FilterThumbnailCell(
                        thumbnail: thumbnail,
                        isSelected: thumbnail.filter == viewModel.selectedFilter,
                        action: { viewModel.selectFilter(thumbnail.filter) }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}
