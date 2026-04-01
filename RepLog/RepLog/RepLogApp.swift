//
//  RepLogApp.swift
//  RepLog
//
//  Created by 徐浩 on 01/04/2026.
//

import SwiftUI
import SwiftData

@main
struct RepLogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WorkoutSession.self, ExerciseEntry.self, ExerciseSet.self])
    }
}
