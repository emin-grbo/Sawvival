//
//  ExampleView.swift
//  SomeProject
//
//  Created by You on 3/20/25.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject private var gameManager: GameManager
  @State private var userAnswer = ""
  @State private var showingShareSheet = false
  @State private var showingResult = false
  @State private var currentTime = Date()
  @State private var progress: Double = 0
  @FocusState private var isAnswerFocused
  
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
  
  func clearAndDismiss() {
    userAnswer = ""
    isAnswerFocused = false
  }
  
  var body: some View {
    ZStack {
      VStack(spacing: 20) {
        if !gameManager.isChallenger && gameManager.gameState != .waiting {
          Image("guy")
            .resizable()
            .scaledToFit()
            .frame(height: 200)
            .padding(.top, -20)
          Spacer()
        }
        
        if gameManager.gameState == .waiting || gameManager.isChallenger {
          Text("Math Quiz")
            .font(.largeTitle)
            .bold()
        }
        
        if gameManager.viewingResult,
           let question = gameManager.currentQuestion {
          VStack(spacing: 15) {
            Text("\(question.firstNumber) \(question.operation) \(question.secondNumber)")
              .font(.title2)
            
            VStack(spacing: 10) {
              Text("Your Friend: \(gameManager.challengerCorrect ? "Correct " : "Wrong ")")
                .foregroundColor(gameManager.challengerCorrect ? .green : .red)
              Text("Your answer: \(gameManager.lastAnswerCorrect ? "Correct " : "Wrong ")")
                .foregroundColor(gameManager.lastAnswerCorrect ? .green : .red)
            }
            .bold()
            .padding()
            
            Button("Try Again") {
              gameManager.startNewGame()
            }
            .buttonStyle(.borderedProminent)
          }
          .padding()
        } else if let deadline = gameManager.deadline,
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
        } else if !gameManager.viewingResult {
          Text(gameManager.isChallenger ? "You're the challenger!" : "Solve your friend's challenge!")
            .font(.headline)
          
          Text(questionText)
            .font(.title)
          
          if !(gameManager.gameState == .completed) {
            TextField("Your answer", text: $userAnswer)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .keyboardType(.numberPad)
              .frame(width: 200)
              .focused($isAnswerFocused)
              .onSubmit {
                clearAndDismiss()
              }
            
            Button("Submit Answer") {
              if let answer = Int(userAnswer) {
                clearAndDismiss()
                showingResult = true
                _ = gameManager.submitAnswer(answer)
              }
            }
            .buttonStyle(.borderedProminent)
          }
          
          if showingResult {
            if gameManager.isChallenger {
              Button("Share Challenge") {
                showingShareSheet = true
              }
              .buttonStyle(.bordered)
            } else {
              VStack {
                if gameManager.gameState == .completed {
                  Text("Your answer was \(gameManager.lastAnswerCorrect ? "correct!" : "wrong!")")
                    .foregroundColor(gameManager.lastAnswerCorrect ? .green : .red)
                    .padding(.bottom, 5)
                  Text("Your friend got it \(gameManager.challengerCorrect ? "right" : "wrong")")
                    .padding(.bottom)
                    .foregroundColor(gameManager.challengerCorrect ? .green : .red)
                  
                  Button("Share Back") {
                    showingShareSheet = true
                  }
                  .buttonStyle(.bordered)
                  .padding()
                }
              }
              .bold()
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
    .onAppear {
      clearAndDismiss()
    }
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
      if let question = gameManager.currentQuestion {
        let shareMessage: String = constructShareMessage(for: question)
        ShareSheet(activityItems: [shareMessage])
      }
    }
  }
  
  func constructShareMessage(for question: MathQuestion) -> String {
    if !gameManager.isChallenger {
      let resultUrlString = "sawvival://result?first=\(question.firstNumber)&second=\(question.secondNumber)&operation=\(question.operation)&correct=\(gameManager.lastAnswerCorrect)&challenger_correct=\(gameManager.challengerCorrect)"
      let answerText = gameManager.lastAnswerCorrect ? "I got it right" : "I got it wrong"
      return "\(answerText)! Check both our answers here: \(resultUrlString)"
    } else {
      let urlString = "sawvival://question?first=\(question.firstNumber)&second=\(question.secondNumber)&operation=\(question.operation)&deadline=\(Date().addingTimeInterval(60).timeIntervalSince1970)&challenger_correct=\(gameManager.challengerCorrect)"
      return "I \(gameManager.challengerCorrect ? "solved it correctly" : "got it wrong")! Can you solve it?\n\(question.firstNumber) \(question.operation) \(question.secondNumber) = ?\n\nTry it here: \(urlString)"
    }
  }
  
  struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
      let url = activityItems[0] as! String
      let controller = UIActivityViewController(
        activityItems: [url],
        applicationActivities: nil
      )
      controller.excludedActivityTypes = [
        .assignToContact,
        .addToReadingList,
        .saveToCameraRoll,
        .print
      ]
      return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
  }
}
