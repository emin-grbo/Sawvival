import Foundation

struct MathQuestion {
    let firstNumber: Int
    let secondNumber: Int
    let operation: String
    let correctAnswer: Int
    
    static func generateRandomQuestion() -> MathQuestion {
        let operations = ["+", "-", "×"]
        let operation = operations.randomElement()!
        let first = Int.random(in: 1...20)
        let second = Int.random(in: 1...20)
        
        var answer: Int
        switch operation {
        case "+": answer = first + second
        case "-": answer = first - second
        case "×": answer = first * second
        default: answer = 0
        }
        
        return MathQuestion(firstNumber: first, secondNumber: second, operation: operation, correctAnswer: answer)
    }
}
