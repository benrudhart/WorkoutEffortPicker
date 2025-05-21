// Copyright (c) 2025 Ben Rudhart

import AppleEffortScorePicker
import HealthKit
import SwiftUI

struct DemoView: View {
    @State private var workout: HKWorkout?
    @State private var effortScore: AppleEffortScore?
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
                        AppleEffortScoreCell(score: effortScore) { storeEffortScore($0, workout: workout) }
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
            let workout = try await fetchOrCreateWorkoutMock()
            effortScore = try await store.fetchEffortScore(workout: workout)
            self.workout = workout
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

    private func storeEffortScore(_ score: AppleEffortScore?, workout: HKWorkout) {
        Task {
            do {
                try await store.setEffortScore(score, workout: workout)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}
