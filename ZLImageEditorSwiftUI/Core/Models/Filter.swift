//
//  Filter.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from ZLFilter.swift
//  Original Copyright (c) 2020 Long Zhang <495181165@qq.com>
//  Filter code reference: https://github.com/Yummypets/YPImagePicker
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Filter Type

public enum FilterType: String, CaseIterable, Identifiable {
    case normal
    case chrome
    case fade
    case instant
    case process
    case transfer
    case tone
    case linear
    case sepia
    case mono
    case noir
    case tonal
    case clarendon
    case nashville
    case apply1977
    case toaster

    public var id: String { rawValue }

    var coreImageFilterName: String {
        switch self {
        case .normal: return ""
        case .chrome: return "CIPhotoEffectChrome"
        case .fade: return "CIPhotoEffectFade"
        case .instant: return "CIPhotoEffectInstant"
        case .process: return "CIPhotoEffectProcess"
        case .transfer: return "CIPhotoEffectTransfer"
        case .tone: return "CILinearToSRGBToneCurve"
        case .linear: return "CISRGBToneCurveToLinear"
        case .sepia: return "CISepiaTone"
        case .mono: return "CIPhotoEffectMono"
        case .noir: return "CIPhotoEffectNoir"
        case .tonal: return "CIPhotoEffectTonal"
        case .clarendon, .nashville, .apply1977, .toaster:
            return "" // Custom filters
        }
    }
}

// MARK: - Filter

public struct Filter: Identifiable, Equatable {
    public let id = UUID()
    public let name: String
    public let type: FilterType

    public init(name: String, type: FilterType) {
        self.name = name
        self.type = type
    }

    public static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.type == rhs.type
    }

    /// Apply filter to image
    public func apply(to image: UIImage) -> UIImage {
        guard type != .normal else { return image }

        guard let ciImage = CIImage(image: image) else {
            return image
        }

        let outputImage: CIImage?

        switch type {
        case .normal:
            return image
        case .clarendon:
            outputImage = FilterProcessor.applyClarendon(to: ciImage)
        case .nashville:
            outputImage = FilterProcessor.applyNashville(to: ciImage)
        case .apply1977:
            outputImage = FilterProcessor.apply1977(to: ciImage)
        case .toaster:
            outputImage = FilterProcessor.applyToaster(to: ciImage)
        default:
            outputImage = FilterProcessor.applyBuiltIn(
                filterName: type.coreImageFilterName,
                to: ciImage
            )
        }

        guard let output = outputImage,
              let cgImage = CIContext().createCGImage(output, from: output.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

// MARK: - Predefined Filters

public extension Filter {
    static let all: [Filter] = [
        .normal, .clarendon, .nashville, .apply1977, .toaster,
        .chrome, .fade, .instant, .process, .transfer,
        .tone, .linear, .sepia, .mono, .noir, .tonal
    ]

    static let normal = Filter(name: "Normal", type: .normal)
    static let clarendon = Filter(name: "Clarendon", type: .clarendon)
    static let nashville = Filter(name: "Nashville", type: .nashville)
    static let apply1977 = Filter(name: "1977", type: .apply1977)
    static let toaster = Filter(name: "Toaster", type: .toaster)
    static let chrome = Filter(name: "Chrome", type: .chrome)
    static let fade = Filter(name: "Fade", type: .fade)
    static let instant = Filter(name: "Instant", type: .instant)
    static let process = Filter(name: "Process", type: .process)
    static let transfer = Filter(name: "Transfer", type: .transfer)
    static let tone = Filter(name: "Tone", type: .tone)
    static let linear = Filter(name: "Linear", type: .linear)
    static let sepia = Filter(name: "Sepia", type: .sepia)
    static let mono = Filter(name: "Mono", type: .mono)
    static let noir = Filter(name: "Noir", type: .noir)
    static let tonal = Filter(name: "Tonal", type: .tonal)
}

// MARK: - Filter Processor

enum FilterProcessor {
    /// Apply built-in Core Image filter
    static func applyBuiltIn(filterName: String, to ciImage: CIImage) -> CIImage? {
        let filter = CIFilter(name: filterName)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        return filter?.outputImage
    }

    /// Clarendon filter
    static func applyClarendon(to ciImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(
            red: 127, green: 187, blue: 227, alpha: Int(255 * 0.2),
            rect: ciImage.extent
        )

        return ciImage
            .applyingFilter("CIOverlayBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage
            ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.35,
                "inputBrightness": 0.05,
                "inputContrast": 1.1
            ])
    }

    /// Nashville filter
    static func applyNashville(to ciImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(
            red: 247, green: 176, blue: 153, alpha: Int(255 * 0.56),
            rect: ciImage.extent
        )
        let backgroundImage2 = getColorImage(
            red: 0, green: 70, blue: 150, alpha: Int(255 * 0.4),
            rect: ciImage.extent
        )

        return ciImage
            .applyingFilter("CIDarkenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage
            ])
            .applyingFilter("CISepiaTone", parameters: [
                "inputIntensity": 0.2
            ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.2,
                "inputBrightness": 0.05,
                "inputContrast": 1.1
            ])
            .applyingFilter("CILightenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage2
            ])
    }

    /// 1977 filter
    static func apply1977(to ciImage: CIImage) -> CIImage? {
        let filterImage = getColorImage(
            red: 243, green: 106, blue: 188, alpha: Int(255 * 0.1),
            rect: ciImage.extent
        )
        let backgroundImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.3,
                "inputBrightness": 0.1,
                "inputContrast": 1.05
            ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": 0.3
            ])

        return filterImage
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage
            ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0),
                "inputPoint1": CIVector(x: 0.25, y: 0.20),
                "inputPoint2": CIVector(x: 0.5, y: 0.5),
                "inputPoint3": CIVector(x: 0.75, y: 0.80),
                "inputPoint4": CIVector(x: 1, y: 1)
            ])
    }

    /// Toaster filter
    static func applyToaster(to ciImage: CIImage) -> CIImage? {
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width / 4.0, height / 4.0)
        let radius1 = min(width / 1.5, height / 1.5)

        let color0 = getColor(red: 128, green: 78, blue: 15, alpha: 255)
        let color1 = getColor(red: 79, green: 0, blue: 79, alpha: 255)

        guard let circle = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1
        ])?.outputImage?.cropped(to: ciImage.extent) else {
            return nil
        }

        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.0,
                "inputBrightness": 0.01,
                "inputContrast": 1.1
            ])
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": circle
            ])
    }

    // MARK: - Helper Methods

    static func getColor(red: Int, green: Int, blue: Int, alpha: Int = 255) -> CIColor {
        CIColor(
            red: CGFloat(Double(red) / 255.0),
            green: CGFloat(Double(green) / 255.0),
            blue: CGFloat(Double(blue) / 255.0),
            alpha: CGFloat(Double(alpha) / 255.0)
        )
    }

    static func getColorImage(red: Int, green: Int, blue: Int, alpha: Int = 255, rect: CGRect) -> CIImage {
        let color = getColor(red: red, green: green, blue: blue, alpha: alpha)
        return CIImage(color: color).cropped(to: rect)
    }
}
