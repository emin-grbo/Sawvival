//
//  SawvivalApp.swift
//  Sawvival
//
//  Created by emin on 22/03/2025.
//

import SwiftUI

@main
struct SawvivalApp: App {
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .onOpenURL { url in
                    guard url.scheme == "sawvival",
                          let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                          let queryItems = components.queryItems,
                          let first = queryItems.first(where: { $0.name == "first" })?.value,
                          let second = queryItems.first(where: { $0.name == "second" })?.value,
                          let operation = queryItems.first(where: { $0.name == "operation" })?.value,
                          let firstNum = Int(first),
                          let secondNum = Int(second) else {
                        return
                    }
                    
                    gameManager.handleSharedQuestion(first: firstNum, 
                                                    second: secondNum, 
                                                    operation: operation)
                }
        }
    }
}
