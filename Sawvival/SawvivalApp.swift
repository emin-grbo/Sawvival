//
//  SawvivalApp.swift
//  Sawvival
//
//  Created by emin on 22/03/2025.
//

import SwiftUI
import Foundation

@main
struct SawvivalApp: App {
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .onOpenURL { url in
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                          let queryItems = components.queryItems,
                          let first = queryItems.first(where: { $0.name == "first" })?.value,
                          let second = queryItems.first(where: { $0.name == "second" })?.value,
                          let operation = queryItems.first(where: { $0.name == "operation" })?.value,
                          let firstNum = Int(first),
                          let secondNum = Int(second) else {
                        return
                    }
                    
                    if url.scheme == "sawvival" {
                        if url.host == "question" {
                            if let deadlineStr = queryItems.first(where: { $0.name == "deadline" })?.value,
                               let deadlineTimeInterval = Double(deadlineStr),
                               let challengerCorrectStr = queryItems.first(where: { $0.name == "challenger_correct" })?.value,
                               let challengerWasCorrect = Bool(challengerCorrectStr) {
                                let deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
                                gameManager.handleSharedQuestion(first: firstNum,
                                                               second: secondNum,
                                                               operation: operation,
                                                               deadline: deadline,
                                                               challengerWasCorrect: challengerWasCorrect)
                            }
                        } else if url.host == "result" {
                            if let correctStr = queryItems.first(where: { $0.name == "correct" })?.value,
                               let isCorrect = Bool(correctStr),
                               let challengerCorrectStr = queryItems.first(where: { $0.name == "challenger_correct" })?.value,
                               let challengerWasCorrect = Bool(challengerCorrectStr) {
                                gameManager.showResult(question: MathQuestion(firstNumber: firstNum,
                                                                           secondNumber: secondNum,
                                                                           operation: operation,
                                                                           correctAnswer: 0),
                                                     wasCorrect: isCorrect,
                                                     challengerWasCorrect: challengerWasCorrect)
                            }
                        }
                    }
                }
        }
    }
}
