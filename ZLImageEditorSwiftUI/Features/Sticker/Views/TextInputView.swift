//
//  TextInputView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

/// View for inputting text for text stickers
struct TextInputView: View {
    // MARK: - Properties

    @Binding var text: String
    @Binding var selectedColor: Color
    let onDone: () -> Void
    let onCancel: () -> Void

    @FocusState private var isFocused: Bool
    private let configuration = EditorConfiguration.shared

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Text input
            TextField("Enter text", text: $text, axis: .vertical)
                .font(.title2)
                .foregroundColor(selectedColor)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }

            // Color picker
            ColorPickerView(
                selectedColor: $selectedColor,
                colors: configuration.textColors
            )

            // Buttons
            HStack(spacing: 16) {
                Button("Cancel") {
                    onCancel()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .cornerRadius(12)

                Button("Done") {
                    onDone()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .disabled(text.isEmpty)
            }
        }
        .padding()
        .background(Color.black.opacity(0.9))
    }
}
