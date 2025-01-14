//
//  UploadPDFView.swift
//  AI_Flashcards_Maker
//
//  Created by kevin zhou on 11/24/24.
//
import SwiftUI
import PhotosUI

struct UploadPDFView: View {
    @StateObject private var uploadPDFController = UploadPDFController()
    @Environment(\.presentationMode) var presentationMode
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false

    var onFlashcardsGenerated: ([Flashcard]) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Image to Generate Flashcards")
                .font(.largeTitle)
                .bold()
                .padding()

            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("Select Image")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerView { image in
                    if let image = image {
                        selectedImage = image
                        uploadPDFController.handleSelectedImage(image: image)
                    }
                }
            }

            // Display the selected image
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
            }

            if isLoading {
                ProgressView("Generating Flashcards...")
                    .padding()
            } else {
                Button(action: {
                    isLoading = true
                    uploadPDFController.generateFlashcards()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isLoading = false
                        onFlashcardsGenerated(uploadPDFController.flashcards)
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Generate Flashcards")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .onChange(of: uploadPDFController.selectedImage) { newValue in
            selectedImage = newValue
        }
    }
}
