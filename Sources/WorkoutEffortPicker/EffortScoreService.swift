// Copyright (c) 2025 Ben Rudhart

import UIKit
import HealthKit

@MainActor
protocol EffortScoreServiceProtocol {
    func saveScore(_ score: WorkoutEffortScore?, workout: HKWorkout) async throws
    func fetchScore(workout: HKWorkout) async throws -> WorkoutEffortScore?
}

@available(iOS 18.0, watchOS 11.0, *)
@MainActor
final class EffortScoreService: EffortScoreServiceProtocol {
    private let healthStore: HKHealthStore

    init() {
        self.healthStore = HKHealthStore()
    }

    func saveScore(_ score: WorkoutEffortScore?, workout: HKWorkout) async throws {
        try await healthStore.setEffortScore(score, workout: workout)
    }

    func fetchScore(workout: HKWorkout) async throws -> WorkoutEffortScore? {
        try await healthStore.fetchEffortScore(workout: workout)
    }
}
