import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var gameManager: GameManager
    @State private var userAnswer = ""
    @State private var showingShareSheet = false
    @State private var showingResult = false
    @State private var currentTime = Date()
    @State private var progress: Double = 0
    
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
    
    var timerProgress: Double {
        guard let deadline = gameManager.deadline else { return 0 }
        let totalTime: TimeInterval = 60
        let remainingTime = deadline.timeIntervalSince(currentTime)
        return max(0, min(1, (totalTime - remainingTime) / totalTime))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
              if isAnswering() {
                Image("guy")
                Spacer()
              } else {
                Text("Math Quiz")
                  .font(.largeTitle)
                  .bold()
              }
                
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
            
            if !gameManager.isChallenger {
                Image(systemName: "hourglass")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                    .offset(y: 300 * (1 - progress) - 150)
                    .opacity(0.8)
            }
        }
        .padding()
        .onReceive(timer) { time in
            currentTime = time
            withAnimation(.linear(duration: 0.5)) {
                progress = timerProgress
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
  
  func isAnswering() -> Bool {
    return !gameManager.isChallenger
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
