//
//  ContentView.swift
//  Sawvival
//
//  Created by emin on 22/03/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var gameManager: GameManager
    @State private var userAnswer = ""
    @State private var showingShareSheet = false
    @State private var showingResult = false
    
    var questionText: String {
        guard let question = gameManager.currentQuestion else { return "Start a new game!" }
        return "\(question.firstNumber) \(question.operation) \(question.secondNumber) = ?"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Math Quiz")
                .font(.largeTitle)
                .bold()
            
            if gameManager.gameState == .waiting {
                Button("Start New Game") {
                    gameManager.startNewGame()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text(gameManager.isChallenger ? "You're the challenger!" : "Solve your friend's challenge!")
                    .font(.headline)
                
                Text(questionText)
                    .font(.title)
                
                TextField("Your answer", text: $userAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 200)
                
                Button("Submit Answer") {
                    if let answer = Int(userAnswer) {
                        showingResult = true
                        _ = gameManager.submitAnswer(answer)
                    }
                }
                .buttonStyle(.borderedProminent)
                
                if showingResult {
                    if gameManager.isChallenger {
                        Button("Share Challenge") {
                            showingShareSheet = true
                        }
                        .buttonStyle(.bordered)
                    } else if gameManager.gameState == .completed {
                        VStack {
                            Text("Results:")
                            Text("Challenger: \(gameManager.challengerScore)")
                            Text("You: \(gameManager.opponentScore)")
                            
                            Button("Start New Game") {
                                gameManager.startNewGame()
                                showingResult = false
                                userAnswer = ""
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingShareSheet) {
            if let question = gameManager.currentQuestion {
                let shareURL = "sawvival://question?first=\(question.firstNumber)&second=\(question.secondNumber)&operation=\(question.operation)"
                ShareSheet(activityItems: [shareURL])
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
        .environmentObject(GameManager())
}
