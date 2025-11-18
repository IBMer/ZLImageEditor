//
//  Constants.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import Foundation
import CoreGraphics

enum Constants {
    // MARK: - Drawing

    static let maxDrawLineImageWidth: CGFloat = 600
    static let defaultLineWidth: CGFloat = 5.0

    // MARK: - Animation

    static let defaultAnimationDuration: CGFloat = 0.25
    static let toolbarAnimationDuration: CGFloat = 0.3

    // MARK: - UI

    static let toolbarHeight: CGFloat = 60
    static let toolIconSize: CGFloat = 24
    static let colorPickerItemSize: CGFloat = 30
    static let filterThumbnailSize: CGFloat = 80

    // MARK: - Image Processing

    static let thumbnailSize = CGSize(width: 200, height: 200)
    static let maxImageSize: CGFloat = 4096

    // MARK: - Sticker

    static let minStickerScale: CGFloat = 0.2
    static let maxStickerScale: CGFloat = 4.0
    static let stickerBorderHideDelay: CGFloat = 2.0
}
