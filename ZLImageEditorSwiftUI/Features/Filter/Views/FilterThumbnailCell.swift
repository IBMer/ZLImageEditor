//
//  FilterThumbnailCell.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Single filter thumbnail cell
struct FilterThumbnailCell: View {
    // MARK: - Properties

    let thumbnail: FilterThumbnail
    let isSelected: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Thumbnail image
                Image(uiImage: thumbnail.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Constants.filterThumbnailSize, height: Constants.filterThumbnailSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    }

                // Filter name
                Text(thumbnail.filter.name)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .blue : .primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
