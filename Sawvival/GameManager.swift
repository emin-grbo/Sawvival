import SwiftUI

class GameManager: ObservableObject {
    @Published var currentQuestion: MathQuestion?
    @Published var challengerScore: Int = 0
    @Published var opponentScore: Int = 0
    @Published var isChallenger: Bool = true
    @Published var gameState: GameState = .waiting
    @Published var deadline: Date? = nil
    @Published var hasExpired: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    
    enum GameState {
        case waiting
        case playing
        case completed
        case expired
    }
    
    func startNewGame() {
        currentQuestion = MathQuestion.generateRandomQuestion()
        challengerScore = 0
        opponentScore = 0
        isChallenger = true
        gameState = .playing
//        roundStartTime = Date()
    }
    
    func handleSharedQuestion(first: Int, second: Int, operation: String, deadline: Date) {
        isChallenger = false
        let answer: Int
        switch operation {
        case "+": answer = first + second
        case "-": answer = first - second
        case "×": answer = first * second
        default: answer = 0
        }
        
        self.deadline = deadline
        currentQuestion = MathQuestion(firstNumber: first, 
                                      secondNumber: second, 
                                      operation: operation, 
                                      correctAnswer: answer)
        gameState = .playing
    }
    
    func submitAnswer(_ answer: Int) -> Bool {
        guard let question = currentQuestion else { return false }
        let isCorrect = answer == question.correctAnswer
        lastAnswerCorrect = isCorrect
        
        if isChallenger {
            challengerScore = isCorrect ? 1 : 0
        } else {
            opponentScore = isCorrect ? 1 : 0
            gameState = .completed
        }
        
        return isCorrect
    }
    
    func checkExpiration() {
        guard let deadline = deadline else { return }
        if Date() > deadline {
            hasExpired = true
            gameState = .expired
            opponentScore = 0
        }
    }
}
