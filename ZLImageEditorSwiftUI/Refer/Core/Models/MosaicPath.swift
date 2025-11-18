//
//  MosaicPath.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from ZLPaths.swift
//  Original Copyright (c) 2020 Long Zhang <495181165@qq.com>
//

import UIKit

/// Represents a mosaic drawing path
public class MosaicPath {
    // MARK: - Properties

    public let path: UIBezierPath
    public let ratio: CGFloat
    public let startPoint: CGPoint
    public private(set) var linePoints: [CGPoint] = []

    // MARK: - Initialization

    public init(pathWidth: CGFloat, ratio: CGFloat, startPoint: CGPoint) {
        self.ratio = ratio
        self.startPoint = CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio)

        path = UIBezierPath()
        path.lineWidth = pathWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: startPoint)
    }

    // MARK: - Public Methods

    public func addLine(to point: CGPoint) {
        path.addLine(to: point)
        linePoints.append(CGPoint(x: point.x / ratio, y: point.y / ratio))
    }
}
