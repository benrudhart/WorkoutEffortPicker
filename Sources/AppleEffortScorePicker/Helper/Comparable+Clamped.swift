// Copyright (c) 2025 Ben Rudhart

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        let minClamped = max(self, limits.lowerBound)
        return min(minClamped, limits.upperBound)
    }

    mutating func clamp(to limits: ClosedRange<Self>) {
        self = clamped(to: limits)
    }
}
