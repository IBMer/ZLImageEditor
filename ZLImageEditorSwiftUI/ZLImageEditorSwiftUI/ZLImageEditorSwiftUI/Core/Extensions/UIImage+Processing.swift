//
//  UIImage+Processing.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from UIImage+ZLImageEditor.swift
//  Original Copyright (c) 2020 Long Zhang <495181165@qq.com>
//

import UIKit
import Accelerate

// MARK: - Image Properties

public extension UIImage {
    var width: CGFloat {
        size.width
    }

    var height: CGFloat {
        size.height
    }
}

// MARK: - Orientation & Rotation

public extension UIImage {
    /// Fix image orientation
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        var transform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = CGAffineTransform(translationX: width, y: height)
            transform = transform.rotated(by: .pi)

        case .left, .leftMirrored:
            transform = CGAffineTransform(translationX: width, y: 0)
            transform = transform.rotated(by: .pi / 2)

        case .right, .rightMirrored:
            transform = CGAffineTransform(translationX: 0, y: height)
            transform = transform.rotated(by: -.pi / 2)

        default:
            break
        }

        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        default:
            break
        }

        guard let cgImage, let colorSpace = cgImage.colorSpace else {
            return self
        }

        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        ) else {
            return self
        }

        context.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        guard let newCgImage = context.makeImage() else {
            return self
        }

        return UIImage(cgImage: newCgImage)
    }

    /// Rotate image by orientation
    func rotate(orientation: UIImage.Orientation) -> UIImage {
        guard let imageRef = cgImage else {
            return self
        }

        let rect = CGRect(origin: .zero, size: CGSize(width: imageRef.width, height: imageRef.height))
        var bnds = rect
        var transform = CGAffineTransform.identity

        switch orientation {
        case .up:
            return self
        case .upMirrored:
            transform = transform.translatedBy(x: rect.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .down:
            transform = transform.translatedBy(x: rect.width, y: rect.height)
            transform = transform.rotated(by: .pi)
        case .downMirrored:
            transform = transform.translatedBy(x: 0, y: rect.height)
            transform = transform.scaledBy(x: 1, y: -1)
        case .left:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.translatedBy(x: 0, y: rect.width)
            transform = transform.rotated(by: .pi * 3 / 2)
        case .leftMirrored:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.translatedBy(x: rect.height, y: rect.width)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: .pi * 3 / 2)
        case .right:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.translatedBy(x: rect.height, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .rightMirrored:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: .pi / 2)
        @unknown default:
            return self
        }

        UIGraphicsBeginImageContext(bnds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return self
        }

        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.scaleBy(x: -1, y: 1)
            context.translateBy(x: -rect.height, y: 0)
        default:
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -rect.height)
        }

        context.concatenate(transform)
        context.draw(imageRef, in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }

    /// Rotate image by degrees
    func rotate(degree: CGFloat) -> UIImage? {
        guard let cgImage else {
            return nil
        }

        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let transform = CGAffineTransform(rotationAngle: degree)
        rotatedViewBox.transform = transform
        let rotatedSize = rotatedViewBox.frame.size

        UIGraphicsBeginImageContext(rotatedSize)
        guard let bitmap = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap.rotate(by: degree)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(cgImage, in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    private func swapRectWidthAndHeight(_ rect: CGRect) -> CGRect {
        CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.height, height: rect.width)
    }
}

// MARK: - Resizing

public extension UIImage {
    /// Resize image using UIGraphicsImageRenderer
    func resize(_ size: CGSize, scale: CGFloat? = nil) -> UIImage? {
        guard size.width > 0, size.height > 0 else {
            return nil
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale ?? self.scale

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// Resize image using Accelerate framework (high performance)
    /// - Parameters:
    ///   - size: Target size
    ///   - scale: Scale factor
    ///   - bitsPerComponent: Bits per color component (default: 8)
    ///   - bitsPerPixel: Bits per pixel (default: 32)
    func resize_vI(
        _ size: CGSize,
        scale: CGFloat? = nil,
        bitsPerComponent: UInt32 = 8,
        bitsPerPixel: UInt32 = 32
    ) -> UIImage? {
        guard let cgImage else { return nil }

        var format = vImage_CGImageFormat(
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            colorSpace: nil,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
            version: 0,
            decode: nil,
            renderingIntent: .defaultIntent
        )

        var sourceBuffer = vImage_Buffer()
        defer {
            if #available(iOS 13.0, *) {
                sourceBuffer.free()
            } else {
                sourceBuffer.data.deallocate()
            }
        }

        var error = vImageBuffer_InitWithCGImage(
            &sourceBuffer,
            &format,
            nil,
            cgImage,
            numericCast(kvImageNoFlags)
        )
        guard error == kvImageNoError else { return nil }

        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let destBytesPerRow = destWidth * bytesPerPixel

        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer {
            destData.deallocate()
        }

        var destBuffer = vImage_Buffer(
            data: destData,
            height: vImagePixelCount(destHeight),
            width: vImagePixelCount(destWidth),
            rowBytes: destBytesPerRow
        )

        // Scale the image using vImage (GPU accelerated)
        error = vImageScale_ARGB8888(
            &sourceBuffer,
            &destBuffer,
            nil,
            numericCast(kvImageHighQualityResampling)
        )
        guard error == kvImageNoError else { return nil }

        // Create CGImage from vImage_Buffer
        guard let destCGImage = vImageCreateCGImageFromBuffer(
            &destBuffer,
            &format,
            nil,
            nil,
            numericCast(kvImageNoFlags),
            &error
        )?.takeRetainedValue() else { return nil }
        guard error == kvImageNoError else { return nil }

        // Create UIImage
        return UIImage(cgImage: destCGImage, scale: scale ?? self.scale, orientation: imageOrientation)
    }
}

// MARK: - Image Effects

public extension UIImage {
    /// Generate mosaic image
    func mosaicImage() -> UIImage? {
        guard let currCgImage = cgImage else {
            return nil
        }

        let scale = 8 * width / UIScreen.main.bounds.width
        let currCiImage = CIImage(cgImage: currCgImage)
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currCiImage, forKey: kCIInputImageKey)
        filter?.setValue(scale, forKey: kCIInputScaleKey)

        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        guard let cgImg = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: size)) else {
            return nil
        }

        return UIImage(cgImage: cgImg)
    }

    /// Apply Gaussian blur
    func blurImage(level: CGFloat) -> UIImage? {
        guard let ciImage = toCIImage() else {
            return nil
        }

        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: "inputImage")
        blurFilter?.setValue(level, forKey: "inputRadius")

        guard let outputImage = blurFilter?.outputImage else {
            return nil
        }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    /// Fill image with color
    func fillColor(_ color: UIColor) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let drawRect = CGRect(origin: .zero, size: size)
            color.setFill()
            UIRectFill(drawRect)
            draw(in: drawRect, blendMode: .destinationIn, alpha: 1)
        }
    }
}

// MARK: - Clipping

public extension UIImage {
    /// Clip image with angle and rect
    func clipImage(angle: CGFloat, editRect: CGRect, isCircle: Bool) -> UIImage? {
        let angleInt = ((Int(angle) % 360) - 360) % 360
        var newImage: UIImage = self

        if angleInt == -90 {
            newImage = rotate(orientation: .left)
        } else if angleInt == -180 {
            newImage = rotate(orientation: .down)
        } else if angleInt == -270 {
            newImage = rotate(orientation: .right)
        }

        guard isCircle || editRect.size != newImage.size else {
            return newImage
        }

        let origin = CGPoint(x: -editRect.minX, y: -editRect.minY)
        let format = UIGraphicsImageRendererFormat()
        format.scale = newImage.scale

        let renderer = UIGraphicsImageRenderer(size: editRect.size, format: format)
        let temp = renderer.image { context in
            if isCircle {
                context.cgContext.addEllipse(in: CGRect(origin: .zero, size: editRect.size))
                context.cgContext.clip()
            }
            newImage.draw(at: origin)
        }

        guard let cgi = temp.cgImage else { return temp }
        return UIImage(cgImage: cgi, scale: newImage.scale, orientation: .up)
    }
}

// MARK: - Adjustments

public extension UIImage {
    /// Adjust brightness, contrast, and saturation
    /// - Parameters:
    ///   - brightness: value in [-1, 1]
    ///   - contrast: value in [-1, 1]
    ///   - saturation: value in [-1, 1]
    func adjust(brightness: Float, contrast: Float, saturation: Float) -> UIImage? {
        guard let ciImage = toCIImage() else {
            return self
        }

        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(filterBrightness(brightness), forKey: kCIInputBrightnessKey)
        filter?.setValue(filterContrast(contrast), forKey: kCIInputContrastKey)
        filter?.setValue(filterSaturation(saturation), forKey: kCIInputSaturationKey)

        guard let outputCIImage = filter?.outputImage else {
            return self
        }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return self
        }

        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }

    private func filterBrightness(_ value: Float) -> Float {
        // Range: -1...1, default 0, use -0.33...0.33
        value / 3
    }

    private func filterContrast(_ value: Float) -> Float {
        // Range: 0...4, default 1, use 0.5...2.5
        if value < 0 {
            return 1 + value * (1 / 2)
        } else {
            return 1 + value * (3 / 2)
        }
    }

    private func filterSaturation(_ value: Float) -> Float {
        // Range: 0...2, default 1
        if value < 0 {
            return 1 + value
        } else {
            return 1 + value
        }
    }
}

// MARK: - Compression

public extension UIImage {
    /// Compress image to target size (in bytes)
    /// - Warning: Changes transparent background as JPEG doesn't support it
    func compress(to maxSize: Int) -> UIImage {
        if let size = jpegData(compressionQuality: 1)?.count, size <= maxSize {
            return self
        }

        var min: CGFloat = 0
        var max: CGFloat = 1
        var data: Data?

        // Binary search for optimal compression quality (6 iterations)
        for _ in 0..<6 {
            let mid = (min + max) / 2
            data = jpegData(compressionQuality: mid)
            let compressSize = data?.count ?? 0

            if compressSize > maxSize {
                max = mid
            } else if compressSize < maxSize {
                min = mid
            } else {
                break
            }
        }

        guard let data else {
            return self
        }

        return UIImage(data: data) ?? self
    }
}

// MARK: - CIImage Conversion

public extension UIImage {
    /// Convert to CIImage
    func toCIImage() -> CIImage? {
        var ciImage = self.ciImage
        if ciImage == nil, let cgImage {
            ciImage = CIImage(cgImage: cgImage)
        }
        return ciImage
    }
}

public extension CIImage {
    /// Convert to UIImage
    func toUIImage() -> UIImage? {
        let context = CIContext()
        guard let cgImage = context.createCGImage(self, from: extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
