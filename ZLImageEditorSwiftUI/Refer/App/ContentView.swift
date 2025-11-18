//
//  ContentView.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var showImageEditor = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                } else {
                    placeholderView
                }

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images
                ) {
                    Label("Select Photo", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImage = image
                        }
                    }
                }
                .padding(.horizontal)

                if selectedImage != nil {
                    Button {
                        showImageEditor = true
                    } label: {
                        Label("Edit Image", systemImage: "slider.horizontal.3")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("ZLImageEditor")
            .fullScreenCover(isPresented: $showImageEditor) {
                if let image = selectedImage {
                    ImageEditorView(
                        originalImage: image,
                        onComplete: { editedImage in
                            selectedImage = editedImage
                            showImageEditor = false
                        },
                        onCancel: {
                            showImageEditor = false
                        }
                    )
                }
            }
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No image selected")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Tap 'Select Photo' to begin")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
