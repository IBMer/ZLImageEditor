//
//  ClipRatio.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from ZLImageEditorConfiguration.swift
//  Original Copyright (c) 2020 Long Zhang <495181165@qq.com>
//

import Foundation
import CoreGraphics

/// Represents a clip ratio option
public struct ClipRatio: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let whRatio: CGFloat
    public let isCircle: Bool

    public init(title: String, whRatio: CGFloat, isCircle: Bool = false) {
        self.title = title
        self.whRatio = isCircle ? 1 : whRatio
        self.isCircle = isCircle
    }

    public static func == (lhs: ClipRatio, rhs: ClipRatio) -> Bool {
        lhs.whRatio == rhs.whRatio && lhs.isCircle == rhs.isCircle
    }
}

// MARK: - Predefined Ratios

public extension ClipRatio {
    static let all: [ClipRatio] = [
        .custom, .circle, .wh1x1, .wh3x4, .wh4x3,
        .wh2x3, .wh3x2, .wh9x16, .wh16x9
    ]

    static let custom = ClipRatio(title: "Custom", whRatio: 0)
    static let circle = ClipRatio(title: "Circle", whRatio: 1, isCircle: true)
    static let wh1x1 = ClipRatio(title: "1:1", whRatio: 1)
    static let wh3x4 = ClipRatio(title: "3:4", whRatio: 3.0 / 4.0)
    static let wh4x3 = ClipRatio(title: "4:3", whRatio: 4.0 / 3.0)
    static let wh2x3 = ClipRatio(title: "2:3", whRatio: 2.0 / 3.0)
    static let wh3x2 = ClipRatio(title: "3:2", whRatio: 3.0 / 2.0)
    static let wh9x16 = ClipRatio(title: "9:16", whRatio: 9.0 / 16.0)
    static let wh16x9 = ClipRatio(title: "16:9", whRatio: 16.0 / 9.0)
}
