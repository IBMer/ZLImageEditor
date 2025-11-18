//
//  DrawPath.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from ZLPaths.swift
//  Original Copyright (c) 2020 Long Zhang <495181165@qq.com>
//

import UIKit

/// Represents a drawing path with smooth Catmull-Rom spline interpolation
public class DrawPath {
    private static var pathIndex = 0

    // MARK: - Properties

    public let pathColor: UIColor
    public let ratio: CGFloat
    public let index: Int
    public var willDelete = false

    private var bgPath: UIBezierPath
    private(set) var path: UIBezierPath
    private var points: [CGPoint] = []

    // MARK: - Initialization

    public init(
        pathColor: UIColor,
        pathWidth: CGFloat,
        defaultLinePath: CGFloat,
        ratio: CGFloat,
        startPoint: CGPoint
    ) {
        self.pathColor = pathColor
        self.ratio = ratio
        self.index = Self.pathIndex
        Self.pathIndex += 1

        // Initialize main path
        path = UIBezierPath()
        path.lineWidth = pathWidth / ratio
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio))

        // Initialize background path (for eraser)
        bgPath = UIBezierPath()
        bgPath.lineWidth = pathWidth / ratio + defaultLinePath
        bgPath.lineCapStyle = .round
        bgPath.lineJoinStyle = .round
        bgPath.move(to: CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio))

        points.append(startPoint)
    }

    // MARK: - Public Methods

    public func addLine(to point: CGPoint) {
        points.append(point)

        func divRatio(_ point: CGPoint) -> CGPoint {
            CGPoint(x: point.x / ratio, y: point.y / ratio)
        }

        guard points.count >= 4 else {
            path.addLine(to: divRatio(point))
            bgPath.addLine(to: divRatio(point))
            return
        }

        // Rebuild path with smooth Catmull-Rom spline
        path.removeAllPoints()
        bgPath.removeAllPoints()

        // https://blog.csdn.net/ChasingDreamsCoder/article/details/53015694
        path.move(to: divRatio(points[0]))
        path.addLine(to: divRatio(points[1]))
        bgPath.move(to: divRatio(points[0]))
        bgPath.addLine(to: divRatio(points[1]))

        let granularity = 4
        for i in 3..<points.count {
            let p0 = points[i - 3]
            let p1 = points[i - 2]
            let p2 = points[i - 1]
            let p3 = points[i]

            // Catmull-Rom spline interpolation
            for j in 1..<granularity {
                let t = CGFloat(j) / CGFloat(granularity)
                let tt = t * t
                let ttt = tt * t

                var interpolatedPoint = CGPoint.zero
                interpolatedPoint.x = 0.5 * (
                    2 * p1.x + (p2.x - p0.x) * t +
                    (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * tt +
                    (3 * p1.x - p0.x - 3 * p2.x + p3.x) * ttt
                )
                interpolatedPoint.y = 0.5 * (
                    2 * p1.y + (p2.y - p0.y) * t +
                    (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * tt +
                    (3 * p1.y - p0.y - 3 * p2.y + p3.y) * ttt
                )
                path.addLine(to: divRatio(interpolatedPoint))
                bgPath.addLine(to: divRatio(interpolatedPoint))
            }

            path.addLine(to: divRatio(p2))
            bgPath.addLine(to: divRatio(p2))
        }

        path.addLine(to: divRatio(points[points.count - 1]))
        bgPath.addLine(to: divRatio(points[points.count - 1]))
    }

    public func drawPath() {
        if willDelete {
            UIColor.white.set()
            bgPath.stroke()
        }

        pathColor.set()
        path.stroke()
    }
}
