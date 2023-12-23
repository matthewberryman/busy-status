//
//  Busy_StatusApp.swift
//  Busy Status
//
//  Created by Matthew Berryman on 21/12/2023.
//

import SwiftUI
import SwiftData

@main
struct Busy_StatusApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Board.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
