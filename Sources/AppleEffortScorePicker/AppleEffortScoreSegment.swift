// Copyright (c) 2025 Ben Rudhart

import SwiftUI

enum AppleEffortScoreSegment: String, CaseIterable {
    case easy
    case moderate
    case hard
    case allOut
}

extension AppleEffortScoreSegment: Identifiable {
    var id: String {
        rawValue
    }
}

@available(iOS 18.0, watchOS 11.0, *)
extension AppleEffortScoreSegment {
    /// All scores that belong to this segment, ordered.
    var scores: [AppleEffortScore] {
        AppleEffortScore.allCases.filter { $0.segment == self }
    }

    var localizedTitle: LocalizedStringKey {
        switch self {
        case .easy: "scoreSegment.easy.title"
        case .moderate: "scoreSegment.moderate.title"
        case .hard: "scoreSegment.hard.title"
        case .allOut: "scoreSegment.allOut.title"
        }
    }

    var localizedDescription: LocalizedStringKey {
        switch self {
        case .easy: "scoreSegment.easy.description"
        case .moderate: "scoreSegment.moderate.description"
        case .hard: "scoreSegment.hard.description"
        case .allOut: "scoreSegment.allOut.description"
        }
    }
}
