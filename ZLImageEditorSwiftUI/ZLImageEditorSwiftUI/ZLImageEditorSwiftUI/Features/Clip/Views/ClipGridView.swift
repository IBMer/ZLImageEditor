//
//  ClipGridView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Grid lines overlay for rule of thirds
struct ClipGridView: View {
    // MARK: - Properties

    let clipRect: CGRect

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let rect = clipRect

                // Vertical lines (rule of thirds)
                let v1 = rect.minX + rect.width / 3
                let v2 = rect.minX + rect.width * 2 / 3

                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: v1, y: rect.minY))
                        path.addLine(to: CGPoint(x: v1, y: rect.maxY))
                    },
                    with: .color(.white.opacity(0.5)),
                    lineWidth: 1
                )

                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: v2, y: rect.minY))
                        path.addLine(to: CGPoint(x: v2, y: rect.maxY))
                    },
                    with: .color(.white.opacity(0.5)),
                    lineWidth: 1
                )

                // Horizontal lines (rule of thirds)
                let h1 = rect.minY + rect.height / 3
                let h2 = rect.minY + rect.height * 2 / 3

                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: rect.minX, y: h1))
                        path.addLine(to: CGPoint(x: rect.maxX, y: h1))
                    },
                    with: .color(.white.opacity(0.5)),
                    lineWidth: 1
                )

                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: rect.minX, y: h2))
                        path.addLine(to: CGPoint(x: rect.maxX, y: h2))
                    },
                    with: .color(.white.opacity(0.5)),
                    lineWidth: 1
                )

                // Border rectangle
                context.stroke(
                    Path(rect),
                    with: .color(.white),
                    lineWidth: 2
                )
            }
        }
        .allowsHitTesting(false)
    }
}
