// Copyright (c) 2025 Ben Rudhart

import HealthKit

@available(iOS 18.0, watchOS 11.0, *)
public extension HKHealthStore {
    // MARK: - Fetch Effort Score

    func fetchEffortScore(workout: HKWorkout) async throws -> AppleEffortScore? {
        try await requestEffortScoreReadWriteAuthorization()

        let sample = try await fetchFirstEffortSample(workout: workout)
        let scoreValue = sample?.quantity.doubleValue(for: .appleEffortScore())
        return scoreValue.flatMap { AppleEffortScore(rawValue: Int($0)) }
    }

    private func fetchFirstEffortSample(workout: HKWorkout) async throws -> HKQuantitySample? {
        try await withCheckedThrowingContinuation { continuation in
            let query = fistEffortSampleQuery(workout: workout, continuation: continuation)
            execute(query)
        }
    }

    private func fistEffortSampleQuery(workout: HKWorkout, continuation: CheckedContinuation<HKQuantitySample?, Error>) -> HKSampleQuery {
        let predicate = HKQuery.predicateForWorkoutEffortSamplesRelated(workout: workout, activity: nil)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return HKSampleQuery(
            sampleType: .effortType,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            if let error {
                continuation.resume(throwing: error)
            } else {
                let sample = results?.first as? HKQuantitySample
                continuation.resume(returning: sample)
            }
        }
    }

    // MARK: - Set Effort Score

    func setEffortScore(_ score: AppleEffortScore?, workout: HKWorkout) async throws {
        try await requestEffortScoreReadWriteAuthorization()

        if let score {
            try await relateWorkoutEffortSample(score: score, workout: workout)
        } else {
            try await deleteWorkoutEffort(for: workout)
        }
    }

    private func relateWorkoutEffortSample(score: AppleEffortScore, workout: HKWorkout) async throws {
        let sample = HKQuantitySample(
            type: .effortType,
            quantity: score.hkQuantity,
            start: workout.startDate,
            end: workout.endDate
        )

        try await relateWorkoutEffortSample(sample, with: workout, activity: nil)
    }

    private func deleteWorkoutEffort(for workout: HKWorkout) async throws {
        guard let sample = try await fetchFirstEffortSample(workout: workout) else {
            assertionFailure("no previous sample related with workout")
            return
        }

        try await delete(sample)
        try await unrelateWorkoutEffortSample(sample, from: workout, activity: nil) // probably not required, just to be safe.
    }

    func requestEffortScoreReadWriteAuthorization() async throws {
        try await requestAuthorization(toShare: [.effortType], read: [.effortType])
    }
}

@available(iOS 18.0, watchOS 11.0, *)
extension HKObjectType {
    static let effortType = HKQuantityType(.workoutEffortScore)
}
