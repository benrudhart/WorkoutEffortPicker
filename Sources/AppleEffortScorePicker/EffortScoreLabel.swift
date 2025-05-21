// Copyright (c) 2025 Ben Rudhart

import SwiftUI

@available(iOS 18.0, watchOS 11.0, *)
struct EffortScoreLabel: View {
    let score: AppleEffortScore
    let isList: Bool

    var body: some View {
        Label {
            title
        } icon: {
            icon
        }
#if os(iOS)
        .font(.title2)
#endif
    }

    private var title: some View {
        if let segment = score.segment {
            Text(segment.localizedTitle, bundle: .module)
        } else {
            Text(isList ? "common.skip" : "common.skipped", bundle: .module)
        }
    }

    private var icon: some View {
        EffortScoreIcon(score: score)
            .foregroundStyle(.white, .white.tertiary)
            .imageScale(.large)
            .font(.title3)
#if os(watchOS)
            .fontWeight(.semibold)
#endif
    }
}

struct EffortScoreIcon: View {
    let score: AppleEffortScore?

    var body: some View {
        Image(systemName: systemName)
            .animation(.smooth, value: score)
    }

    private var systemName: String {
        if let score {
            switch score {
            case .skipped:
                "righttriangle.split.diagonal.fill" // TODO: get better image
            default:
                "\(score.rawValue).circle.fill"
            }
        } else {
            "plus.circle"
        }
    }
}

@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    List {
        EffortScoreLabel(score: .skipped, isList: true)
    }
}
