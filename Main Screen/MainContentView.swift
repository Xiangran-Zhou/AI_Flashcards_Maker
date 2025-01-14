//
//  MainContentView.swift
//  AI_Flashcards_Maker
//
//  Created by kevin zhou on 11/24/24.
//
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct MainContentView: View {
    @State private var isLoggedOut = false
    @State private var showUploadPDFView = false
    @State private var flashcards: [Flashcard] = []
    @State private var showAlert = false
    @State private var selectedFlashcard: Flashcard? = nil
    @ObservedObject var mainContentController = MainContentController()
    var username: String

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        isLoggedOut = true
                    }) {
                        Text("Back")
                            .frame(width: 80, height: 40)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Spacer()
                    Text(username)
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)
                    Spacer()
                    Button(action: {
                        mainContentController.logout()
                        isLoggedOut = true
                    }) {
                        Text("Logout")
                            .frame(width: 80, height: 40)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Button to open the Upload PDF screen
                Button(action: {
                    showUploadPDFView = true
                }) {
                    Text("Create Flashcard")
                        .font(.headline)
                        .frame(width: 200, height: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .fullScreenCover(isPresented: $showUploadPDFView) {
                    UploadPDFView { generatedFlashcards in
                        flashcards.append(contentsOf: generatedFlashcards)
                        saveFlashcardsToFirebase(flashcards: generatedFlashcards)
                    }
                }

                // Display the generated flashcards
                if !flashcards.isEmpty {
                    List(flashcards, id: \.term) { flashcard in
                        VStack(alignment: .leading) {
                            Text("Term: \(flashcard.term)")
                                .font(.headline)
                            Text("Explanation: \(flashcard.explanation)")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            selectedFlashcard = flashcard
                            showAlert = true
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Flashcard"),
                    message: Text("Are you sure you want to delete this flashcard?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let flashcardToDelete = selectedFlashcard {
                            deleteFlashcard(flashcard: flashcardToDelete)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .fullScreenCover(isPresented: $isLoggedOut) {
                LoginView()
            }
            .onAppear {
                loadFlashcardsFromFirebase()
            }
        }
    }

    private func saveFlashcardsToFirebase(flashcards: [Flashcard]) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(userID).collection("flashcards")
        
        for flashcard in flashcards {
            // Check if flashcard already exists in Firebase to avoid duplicates
            collectionRef.whereField("term", isEqualTo: flashcard.term)
                .getDocuments { snapshot, _ in
                    if let snapshot = snapshot, snapshot.isEmpty {
                        // If no document with the same term exists, add the new flashcard
                        let data: [String: Any] = [
                            "term": flashcard.term,
                            "explanation": flashcard.explanation,
                            "timestamp": Timestamp()
                        ]
                        collectionRef.addDocument(data: data) { _ in
                        }
                    }
                }
        }
    }
    
    private func loadFlashcardsFromFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(userID).collection("flashcards")
        
        collectionRef.order(by: "timestamp", descending: false).getDocuments { snapshot, _ in
            var loadedFlashcards: [Flashcard] = []
            if let documents = snapshot?.documents {
                for document in documents {
                    let data = document.data()
                    if let term = data["term"] as? String, let explanation = data["explanation"] as? String {
                        loadedFlashcards.append(Flashcard(term: term, explanation: explanation))
                    }
                }
            }
            flashcards = loadedFlashcards
        }
    }

    private func deleteFlashcard(flashcard: Flashcard) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(userID).collection("flashcards")

        // Find the document in Firebase and delete it
        collectionRef.whereField("term", isEqualTo: flashcard.term)
            .getDocuments { snapshot, _ in
                if let documents = snapshot?.documents {
                    for document in documents {
                        document.reference.delete { _ in
                            // Remove from local list
                            if let index = flashcards.firstIndex(where: { $0.term == flashcard.term }) {
                                flashcards.remove(at: index)
                            }
                        }
                    }
                }
            }
    }
}
