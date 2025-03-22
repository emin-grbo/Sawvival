import SwiftUI

class GameManager: ObservableObject {
    @Published var currentQuestion: MathQuestion?
    @Published var challengerScore: Int = 0
    @Published var opponentScore: Int = 0
    @Published var isChallenger: Bool = true
    @Published var gameState: GameState = .waiting
    
    enum GameState {
        case waiting
        case playing
        case completed
    }
    
    func startNewGame() {
        currentQuestion = MathQuestion.generateRandomQuestion()
        challengerScore = 0
        opponentScore = 0
        isChallenger = true
        gameState = .playing
    }
    
    func handleSharedQuestion(first: Int, second: Int, operation: String) {
        isChallenger = false
        let answer: Int
        switch operation {
        case "+": answer = first + second
        case "-": answer = first - second
        case "×": answer = first * second
        default: answer = 0
        }
        
        currentQuestion = MathQuestion(firstNumber: first, 
                                      secondNumber: second, 
                                      operation: operation, 
                                      correctAnswer: answer)
        gameState = .playing
    }
    
    func submitAnswer(_ answer: Int) -> Bool {
        guard let question = currentQuestion else { return false }
        let isCorrect = answer == question.correctAnswer
        
        if isChallenger {
            challengerScore = isCorrect ? 1 : 0
        } else {
            opponentScore = isCorrect ? 1 : 0
            gameState = .completed
        }
        
        return isCorrect
    }
}

