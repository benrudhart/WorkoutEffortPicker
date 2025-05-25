// Copyright (c) 2025 Ben Rudhart

import UIKit
import HealthKit

@available(iOS 18.0, watchOS 11.0, *)
@Observable @MainActor
public final class AppleEffortScoreCellViewModel: AppleEffortScoreCellViewModelProtocol {
    let workout: HKWorkout
    private let healthStore: HKHealthStore
    private var didFetchScore = false
    public private(set) var score: AppleEffortScore?
    public private(set) var isPermissionDenied: Bool

    public init(workout: HKWorkout) {
        self.workout = workout
        self.healthStore = HKHealthStore()
        self.isPermissionDenied = healthStore.authorizationStatus(for: .effortType) == .sharingDenied
        self.isPermissionDenied = true
    }

    public func onForeground() {
        isPermissionDenied = healthStore.authorizationStatus(for: .effortType) == .sharingDenied
    }

    public func saveScore(_ score: AppleEffortScore?) {
        Task {
            do {
                try await healthStore.setEffortScore(score, workout: workout)
                self.score = score
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    public func onAppear() {
        guard !didFetchScore else { return }

        didFetchScore = true
        Task {
            do {
                score = try await healthStore.fetchEffortScore(workout: workout)
            } catch {
                assertionFailure(error.localizedDescription)
                didFetchScore = false
            }
        }
    }
}
