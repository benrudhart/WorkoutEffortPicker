// Copyright (c) 2025 Ben Rudhart

import HealthKit
import SwiftUI

public enum WorkoutEffortScore: Int, Comparable, Sendable {
    /// The user decided to skip the effort for this workout. This differs from not selecting a value at all!
    case skipped = 0
    case easy1 = 1
    case easy2
    case easy3
    case moderate1
    case moderate2
    case moderate3
    case hard1
    case hard2
    case allOut1
    case allOut2
}

extension WorkoutEffortScore: Strideable {
    public static func < (lhs: WorkoutEffortScore, rhs: WorkoutEffortScore) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public func distance(to other: WorkoutEffortScore) -> RawValue {
        other.rawValue - rawValue
    }

    public func advanced(by n: Stride) -> WorkoutEffortScore {
        WorkoutEffortScore(safeScoreValue: rawValue + n)
    }
}

extension WorkoutEffortScore {
    /// Initializes with the given `safeScoreValue`. If it is "out of bounds" the closest bounds will be used
    init(safeScoreValue: Int) {
        if safeScoreValue < 1 {
            self = .easy1
        } else if let score = WorkoutEffortScore(rawValue: safeScoreValue) {
            self = score
        } else {
            self = .allOut2
        }
    }

    @available(iOS 18.0, watchOS 11.0, *)
    var hkQuantity: HKQuantity {
        let value = Double(rawValue)
        return HKQuantity(unit: .appleEffortScore(), doubleValue: value)
    }

    var segment: WorkoutEffortScoreSegment? {
        switch self {
        case .skipped: nil
        case .easy1, .easy2, .easy3: .easy
        case .moderate1, .moderate2, .moderate3: .moderate
        case .hard1, .hard2: .hard
        case .allOut1, .allOut2: .allOut
        }
    }

    var segmentIndex: Int? {
        if let segment,
           let index = WorkoutEffortScoreSegment.allCases.firstIndex(of: segment) {
            return index
        } else {
            return nil
        }
    }

    var color: Color {
        if let segment {
            Color("\(segment)/\(rawValue)Tint", bundle: .module)
        } else {
            .gray // skipped case
        }
    }
}
