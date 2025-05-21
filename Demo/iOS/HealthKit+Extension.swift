// Copyright (c) 2025 Ben Rudhart

import HealthKit

extension HKHealthStore {
    func requestRequiredAuthorization() async throws {
        let workoutType = HKQuantityType.workoutType()
        let effortType = HKQuantityType(.workoutEffortScore)
        try await requestAuthorization(toShare: [workoutType, effortType], read: [workoutType, effortType])
    }

    func fetchLastWorkout() async throws -> HKWorkout? {
        try await withCheckedThrowingContinuation { continuation in
            let query = lastWorkoutQuery(continuation: continuation)
            execute(query)
        }
    }

    private func lastWorkoutQuery(continuation: CheckedContinuation<HKWorkout?, Error>) -> HKSampleQuery {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: workoutActivity)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return HKSampleQuery(
            sampleType: .workoutType(),
            predicate: workoutPredicate,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                continuation.resume(throwing: error)
            }
            guard let workouts = samples as? [HKWorkout] else {
                fatalError("False samples type")
            }

            continuation.resume(returning: workouts.first)
        }
    }

    func mockWorkout() async throws -> HKWorkout {
        let workoutBuilder = makeBuilder()

        let startInterval = TimeInterval.random(in: -1_000_000 ... -100_000)
        try await workoutBuilder.beginCollection(at: Date(timeIntervalSinceNow: startInterval))
        try await workoutBuilder.endCollection(at: Date(timeIntervalSinceNow: TimeInterval.random(in: startInterval...(startInterval + 2000))))

        guard let workout = try await workoutBuilder.finishWorkout() else {
            fatalError("Workout not created")
        }

        return workout
    }

    private func makeBuilder() -> HKWorkoutBuilder {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutActivity

        return HKWorkoutBuilder(
            healthStore: self,
            configuration: configuration,
            device: nil
        )
    }

    func saveWorkout(_ workout: HKWorkout) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            save(workout) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    assert(success, "Workout could not be saved")
                    continuation.resume()
                }
            }
        }
    }

    private var workoutActivity: HKWorkoutActivityType {
        .traditionalStrengthTraining
    }
}
