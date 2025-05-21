// Copyright (c) 2025 Ben Rudhart

import HealthKit
import SwiftUI

public enum AppleEffortScore: Int, CaseIterable, Comparable, Sendable, Strideable {
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

    public static func < (lhs: AppleEffortScore, rhs: AppleEffortScore) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public typealias Stride = Int

    public func distance(to other: AppleEffortScore) -> Stride {
        other.rawValue - rawValue
    }

    public func advanced(by n: Stride) -> AppleEffortScore {
        AppleEffortScore(safeScoreValue: rawValue + n)
    }

    /// Initializes with the given `safeScoreValue`. If it is "out of bounds" the  closest bounds will be used
    init(safeScoreValue: Int) {
        if let score = AppleEffortScore(rawValue: safeScoreValue) {
            self = score
        } else {
            let all = AppleEffortScore.allCases
            let lowerBound = all.min()!
            let upperBound = all.max()!
            self = safeScoreValue < lowerBound.rawValue ? lowerBound : upperBound
        }
    }
}

@available(iOS 18.0, watchOS 11.0, *)
extension AppleEffortScore {
    var hkQuantity: HKQuantity {
        let value = Double(rawValue)
        return HKQuantity(unit: .appleEffortScore(), doubleValue: value)
    }

    var segment: AppleEffortScoreSegment {
        switch self {
        case .easy1, .easy2, .easy3:
            return .easy
        case .moderate1, .moderate2, .moderate3:
            return .moderate
        case .hard1, .hard2:
            return .hard
        case .allOut1, .allOut2:
            return .allOut
        }
    }

    var segmentIndex: Int {
        AppleEffortScoreSegment.allCases.firstIndex(of: segment)!
    }

    var color: Color {
        Color("\(segment)/\(rawValue)Tint", bundle: .module)
    }
}

@available(iOS 18.0, watchOS 11.0, *)
struct BackgroundGradient: View {
    let score: AppleEffortScore?

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.smooth, value: score)
    }

    private var colors: [Color] {
        if let score {
            [
                Color("\(score.segment)/\(score.rawValue)Top", bundle: .module),
                Color("\(score.segment)/\(score.rawValue)Middle", bundle: .module),
                Color("\(score.segment)/\(score.rawValue)Bottom", bundle: .module)
            ]
        } else {
            [
                Color("skipped/Top", bundle: .module),
                Color("skipped/Middle", bundle: .module),
                Color("skipped/Bottom", bundle: .module)
            ]
        }
    }
}
