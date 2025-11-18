//
//  ClipOverlayView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Overlay showing the crop area with darkened outside area
struct ClipOverlayView: View {
    // MARK: - Properties

    let clipRect: CGRect

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Fill entire area with semi-transparent black
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(.black.opacity(0.5))
                )

                // Cut out the clip rectangle (make it transparent)
                context.blendMode = .destinationOut
                context.fill(
                    Path(clipRect),
                    with: .color(.white)
                )
            }
        }
        .allowsHitTesting(false)
    }
}
