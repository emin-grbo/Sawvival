import SwiftUI

class GameManager: ObservableObject {
    @Published var currentQuestion: MathQuestion?
    @Published var isChallenger: Bool = true
    @Published var gameState: GameState = .waiting
    @Published var deadline: Date? = nil
    @Published var hasExpired: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var viewingResult: Bool = false
    @Published var challengerCorrect: Bool = false
    
    enum GameState {
        case waiting
        case playing
        case completed
        case expired
        case viewingResult
    }
    
    func startNewGame() {
        currentQuestion = MathQuestion.generateRandomQuestion()
        isChallenger = true
        gameState = .playing
        viewingResult = false
        deadline = nil
        hasExpired = false
        challengerCorrect = false
        lastAnswerCorrect = false
    }
    
    func handleSharedQuestion(first: Int, second: Int, operation: String, deadline: Date, challengerWasCorrect: Bool) {
        isChallenger = false
        let answer: Int
        switch operation {
        case "+": answer = first + second
        case "-": answer = first - second
        case "×": answer = first * second
        default: answer = 0
        }
        
        self.deadline = deadline
        challengerCorrect = challengerWasCorrect
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
            challengerCorrect = isCorrect
        } else {
            gameState = .completed
        }
        
        return isCorrect
    }
    
    func checkExpiration() {
        guard let deadline = deadline else { return }
        if Date() > deadline {
            hasExpired = true
            gameState = .expired
            lastAnswerCorrect = false
        }
    }
    
    func showResult(question: MathQuestion, wasCorrect: Bool, challengerWasCorrect: Bool) {
        currentQuestion = question
        lastAnswerCorrect = wasCorrect
        challengerCorrect = challengerWasCorrect
        viewingResult = true
        gameState = .viewingResult
        deadline = nil
        hasExpired = false
        isChallenger = true
    }
}
