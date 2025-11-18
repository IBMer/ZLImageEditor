//
//  AdjustStatus.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from ZLEditImageViewController.swift
//  Original Copyright (c) 2020 Long Zhang <495181165@qq.com>
//

import Foundation

/// Represents the current adjustment status
public struct AdjustStatus: Equatable {
    public var brightness: Float
    public var contrast: Float
    public var saturation: Float

    public var allValueIsZero: Bool {
        brightness == 0 && contrast == 0 && saturation == 0
    }

    public init(
        brightness: Float = 0,
        contrast: Float = 0,
        saturation: Float = 0
    ) {
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
    }
}
