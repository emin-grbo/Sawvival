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
        
        // Adjust second number based on operation to prevent negative results
        let second: Int
        switch operation {
        case "+":
            second = Int.random(in: 1...20)
        case "-":
            second = Int.random(in: 1...first) // Ensure second number is not larger than first
        case "×":
            second = Int.random(in: 1...10)  // Smaller range for multiplication
        default:
            second = 1
        }
        
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
