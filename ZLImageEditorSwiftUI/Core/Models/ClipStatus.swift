//
//  ClipStatus.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from ZLEditImageViewController.swift
//  Original Copyright (c) 2020 Long Zhang <495181165@qq.com>
//

import Foundation
import CoreGraphics

/// Represents the current clipping status
public struct ClipStatus: Equatable {
    public var editRect: CGRect
    public var angle: CGFloat
    public var ratio: ClipRatio?

    public init(
        editRect: CGRect,
        angle: CGFloat = 0,
        ratio: ClipRatio? = nil
    ) {
        self.editRect = editRect
        self.angle = angle
        self.ratio = ratio
    }
}
