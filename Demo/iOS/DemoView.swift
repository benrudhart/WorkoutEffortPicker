// Copyright (c) 2025 Ben Rudhart

import AppleEffortScorePicker
import HealthKit
import SwiftUI

struct DemoView: View {
    @State private var workout: HKWorkout?
    private let store = HKHealthStore()

    var body: some View {
        NavigationStack {
            List {
                if let workout {
                    Section("Workout") {
                        LabeledContent("Date", value: workout.startDate.formatted(date: .numeric, time: .omitted))
                        LabeledContent("Duration", value: Duration.seconds(workout.duration).formatted())
                    }

                    Section("Effort") {
                        AppleEffortScoreCell(viewModel: AppleEffortScoreCellViewModel(workout: workout))
                    }
                }
            }
            .navigationTitle("Demo")
        }
        .task(fetchInitialData)
    }

    private func fetchInitialData() async {
        guard workout == nil else { return }

        do {
            workout = try await fetchOrCreateWorkoutMock()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// fetches the last stored workout or mocks a new one
    private func fetchOrCreateWorkoutMock() async throws -> HKWorkout {
        try await store.requestRequiredAuthorization()

        if let workout = try await store.fetchLastWorkout() {
            return workout
        } else {
            let workout = try await store.mockWorkout()
            try await store.saveWorkout(workout)
            return workout
        }
    }
}
