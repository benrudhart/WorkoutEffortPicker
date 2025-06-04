// Copyright (c) 2025 Ben Rudhart

import SwiftUI

@available(iOS 14.0, watchOS 7.0, *)
struct BackgroundGradient: View {
    let score: WorkoutEffortScore?

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.smooth, value: score)
    }

    private var colors: [Color] {
        if let score,
           let segment = score.segment {
            [
                Color("\(segment)/\(score.rawValue)Top", bundle: .module),
                Color("\(segment)/\(score.rawValue)Middle", bundle: .module),
                Color("\(segment)/\(score.rawValue)Bottom", bundle: .module)
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
