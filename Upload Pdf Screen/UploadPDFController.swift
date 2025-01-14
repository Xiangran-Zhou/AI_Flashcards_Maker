//
//  UploadPDFController.swift
//  AI_Flashcards_Maker
//
//  Created by kevin zhou on 11/24/24.
//
import Foundation
import PDFKit
import Vision
import UIKit
import FirebaseFirestore
import FirebaseAuth

class UploadPDFController: ObservableObject {
    @Published var selectedFile: URL?
    @Published var flashcards: [Flashcard] = []
    @Published var selectedImage: UIImage?

    func handleSelectedImage(image: UIImage) {
        selectedImage = image
    }

    func generateFlashcards() {
        if let image = selectedImage {
            generateFlashcardsFromImage(image: image)
        }
    }

    private func generateFlashcardsFromImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] (request, _) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let recognizedTexts = observations.compactMap { $0.topCandidates(1).first?.string }
            let extractedText = recognizedTexts.joined(separator: "\n")

            // Send extracted text to GPT for flashcard generation
            self?.generateFlashcardsWithGPT(from: extractedText)
        }

        do {
            try requestHandler.perform([request])
        } catch {
            return
        }
    }

    private func generateFlashcardsWithGPT(from text: String) {
        guard let apiKey = getAPIKey() else {
            return
        }

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        Analyze the following text. Extract all technical or professional terms and provide their accurate and concise explanations.
        Format the response as:
        Term: <Term>
        Explanation: <Explanation>

        Text: \(text)
        """
        let json: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 1500,
            "temperature": 0.7
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        } catch {
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let data = data else {
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]] {
                var generatedFlashcards: [Flashcard] = []
                for choice in choices {
                    if let message = choice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        let components = content.components(separatedBy: "\n")
                        var term: String? = nil
                        var explanation: String? = nil
                        for component in components {
                            if component.starts(with: "Term:") {
                                term = component.replacingOccurrences(of: "Term: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                            } else if component.starts(with: "Explanation:") {
                                explanation = component.replacingOccurrences(of: "Explanation: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                            if let termUnwrapped = term, let explanationUnwrapped = explanation {
                                generatedFlashcards.append(Flashcard(term: termUnwrapped, explanation: explanationUnwrapped))
                                term = nil
                                explanation = nil
                            }
                        }
                    }
                }

                DispatchQueue.main.async {
                    self?.flashcards = generatedFlashcards
                    self?.saveFlashcardsToFirebase(flashcards: generatedFlashcards) // Save flashcards to Firebase
                }
            }
        }

        task.resume()
    }

    private func saveFlashcardsToFirebase(flashcards: [Flashcard]) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(userID).collection("flashcards")
        
        for flashcard in flashcards {
            let data: [String: Any] = [
                "term": flashcard.term,
                "explanation": flashcard.explanation,
                "timestamp": Timestamp()
            ]
            collectionRef.addDocument(data: data) { _ in
            }
        }
    }

    private func getAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            return nil
        }
        return dictionary["OpenAI_API_Key"] as? String
    }
}

struct Flashcard {
    var term: String
    var explanation: String
}



