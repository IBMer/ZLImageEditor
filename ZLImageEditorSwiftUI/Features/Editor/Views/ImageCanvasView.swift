//
//  ImageCanvasView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// Canvas view for displaying the image being edited
struct ImageCanvasView: View {
    // MARK: - Properties

    let image: UIImage

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
