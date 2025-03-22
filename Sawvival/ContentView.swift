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
    @State private var currentTime = Date()
    
    // Add timer to update every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var questionText: String {
        guard let question = gameManager.currentQuestion else { return "Start a new game!" }
        return "\(question.firstNumber) \(question.operation) \(question.secondNumber) = ?"
    }
    
    var timeRemaining: String {
        guard let deadline = gameManager.deadline else { return "" }
        let diff = Calendar.current.dateComponents([.minute, .second], from: currentTime, to: deadline)
        let totalSeconds = (diff.minute ?? 0) * 60 + (diff.second ?? 0)
        if totalSeconds <= 0 {
            return "Time's up!"
        }
        return String(format: "%02d:%02d", diff.minute ?? 0, diff.second ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Math Quiz")
                .font(.largeTitle)
                .bold()
            
            if let deadline = gameManager.deadline,
               !gameManager.isChallenger {
                Text(timeRemaining)
                    .font(.headline)
                    .foregroundColor(gameManager.hasExpired ? .white : .blue)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(gameManager.hasExpired ? Color.red : Color.blue.opacity(0.2))
                    )
                    .scaleEffect(gameManager.hasExpired ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: gameManager.hasExpired)
            }
            
            if gameManager.gameState == .expired {
                Text("You lost! Time expired!")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
            } else if gameManager.gameState == .waiting {
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
        .onReceive(timer) { time in
            currentTime = time
            withAnimation {
                if !gameManager.isChallenger {
                    gameManager.checkExpiration()
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let question = gameManager.currentQuestion,
               let deadline = gameManager.deadline {
                let shareURL = "sawvival://question?first=\(question.firstNumber)&second=\(question.secondNumber)&operation=\(question.operation)&deadline=\(deadline.timeIntervalSince1970)"
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
