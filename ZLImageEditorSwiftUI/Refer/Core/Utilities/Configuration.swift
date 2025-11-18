//
//  Configuration.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from ZLImageEditorConfiguration.swift
//  Original Copyright (c) 2020 Long Zhang <495181165@qq.com>
//

import SwiftUI

/// Global configuration for the image editor
@Observable
public final class EditorConfiguration {
    // MARK: - Singleton

    public static let shared = EditorConfiguration()

    private init() {}

    // MARK: - Tools

    /// Available editing tools
    public var tools: [EditorTool] = EditorTool.allCases

    // MARK: - Drawing

    /// Available drawing colors
    public var drawColors: [Color] = [
        .white,
        .black,
        .editorRed,
        .editorOrange,
        .editorYellow,
        .editorLightGreen,
        .editorGreen,
        .editorLightBlue,
        .editorBlue,
        .editorPurple,
        .editorGray
    ]

    /// Default drawing color
    public var defaultDrawColor: Color = .editorRed

    /// Default brush size
    public var defaultBrushSize: CGFloat = 5.0

    /// Minimum brush size
    public var minBrushSize: CGFloat = 2.0

    /// Maximum brush size
    public var maxBrushSize: CGFloat = 20.0

    // MARK: - Clipping

    /// Available clip ratios
    public var clipRatios: [ClipRatio] = ClipRatio.all

    // MARK: - Filters

    /// Available filters
    public var filters: [Filter] = Filter.all

    // MARK: - Adjustments

    /// Available adjustment tools
    public var adjustmentTools: [AdjustmentTool] = AdjustmentTool.allCases

    /// Brightness range
    public var brightnessRange: ClosedRange<Float> = -0.33...0.33

    /// Contrast range
    public var contrastRange: ClosedRange<Float> = 0.5...2.5

    /// Saturation range
    public var saturationRange: ClosedRange<Float> = 0...2

    // MARK: - Text Sticker

    /// Default text color
    public var defaultTextColor: Color = .white

    /// Default text font
    public var defaultTextFont: UIFont = .boldSystemFont(ofSize: 32)

    /// Available text colors
    public var textColors: [Color] = [
        .white,
        .black,
        .editorRed,
        .editorOrange,
        .editorYellow,
        .editorGreen,
        .editorBlue,
        .editorPurple
    ]

    // MARK: - Mosaic

    /// Default mosaic line width
    public var defaultMosaicLineWidth: CGFloat = 25.0

    /// Minimum mosaic line width
    public var minMosaicLineWidth: CGFloat = 15.0

    /// Maximum mosaic line width
    public var maxMosaicLineWidth: CGFloat = 50.0

    // MARK: - Methods

    /// Reset configuration to defaults
    public func reset() {
        tools = EditorTool.allCases
        drawColors = [
            .white, .black, .editorRed, .editorOrange,
            .editorYellow, .editorLightGreen, .editorGreen,
            .editorLightBlue, .editorBlue, .editorPurple, .editorGray
        ]
        defaultDrawColor = .editorRed
        defaultBrushSize = 5.0
        clipRatios = ClipRatio.all
        filters = Filter.all
        adjustmentTools = AdjustmentTool.allCases
    }
}

// MARK: - Adjustment Tool

public enum AdjustmentTool: String, CaseIterable, Identifiable {
    case brightness
    case contrast
    case saturation

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .brightness: return "Brightness"
        case .contrast: return "Contrast"
        case .saturation: return "Saturation"
        }
    }

    public var iconName: String {
        switch self {
        case .brightness: return "sun.max"
        case .contrast: return "circle.lefthalf.filled"
        case .saturation: return "drop.fill"
        }
    }

    public var key: String {
        switch self {
        case .brightness: return kCIInputBrightnessKey
        case .contrast: return kCIInputContrastKey
        case .saturation: return kCIInputSaturationKey
        }
    }

    public func filterValue(_ value: Float) -> Float {
        switch self {
        case .brightness:
            // Range: -1...1, default 0, use -0.33...0.33
            return value / 3
        case .contrast:
            // Range: 0...4, default 1, use 0.5...2.5
            if value < 0 {
                return 1 + value * (1 / 2)
            } else {
                return 1 + value * (3 / 2)
            }
        case .saturation:
            // Range: 0...2, default 1
            if value < 0 {
                return 1 + value
            } else {
                return 1 + value
            }
        }
    }
}
