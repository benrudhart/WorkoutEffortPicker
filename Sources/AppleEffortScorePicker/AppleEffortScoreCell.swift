// Copyright (c) 2025 Ben Rudhart

import SwiftUI

@available(iOS 18.0, watchOS 11.0, *)
public struct AppleEffortScoreCell: View {
    @State private var score: AppleEffortScore?
    @State private var isScoreViewPresented = false
    let onSaveScore: (AppleEffortScore?) -> Void

    public init(score: AppleEffortScore? = nil, onSaveScore: @escaping (AppleEffortScore?) -> Void) {
        self.score = score
        self.onSaveScore = onSaveScore
    }

    public var body: some View {
        content
            .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var content: some View {
#if os(iOS)
        Button {
            isScoreViewPresented = true
        } label: {
            buttonLabel
        }
        .foregroundStyle(.white)
        .sheet(isPresented: $isScoreViewPresented, content: scoreView)
#else
        NavigationLink {
            scoreView()
        } label: {
            buttonLabel
        }
        .buttonBorderShape(.roundedRectangle)
#endif
    }

    private var buttonLabel: some View {
        VStack(alignment: .leading) {
            title
#if os(watchOS)
            contentLabel
#else
            labeledContent
#endif
        }
    }

    private func scoreView() -> some View {
        EffortScoreView(score: score, onSaveScore: saveScore(_:))
    }

    private func saveScore(_ score: AppleEffortScore?) {
        self.score = score
        onSaveScore(score)
    }

    private var title: some View {
        HStack {
            Text("scoreCell.effort", bundle: .module)
#if os(watchOS)
                .frame(maxWidth: .infinity, alignment: .leading)
#endif
            Image(systemName: "plusminus")
                .imageScale(.small)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
#if os(watchOS)
        .textCase(.uppercase)
#endif
    }

    private var labeledContent: some View {
        HStack {
            contentLabel
                .frame(maxWidth: .infinity, alignment: .leading)
            scoreIcon
        }
        .font(.title2)
    }

    private var contentLabel: some View {
        HStack {
            EffortScoreIcon(score: score)
                .symbolRenderingMode(score != nil ? .hierarchical : .monochrome)
#if os(watchOS)
                .imageScale(.small)
#endif

            if let score {
                let key = score.segment?.localizedTitle ?? "common.skipped"
                Text(key, bundle: .module)
            } else {
                Text("scoreCell.addEffort", bundle: .module)
                    .font(.title)
            }
        }
        .foregroundStyle(color)
#if os(watchOS)
        .font(.title2)
        .fontWeight(.medium)
        .fontDesign(.rounded)
#endif
    }

    private var color: Color {
        score?.color ?? .gray
    }

    /// TODO: improve icon by creating custom one
    private var scoreIcon: some View {
        let value = Double(score?.rawValue ?? 0) / Double(AppleEffortScore.allOut2.rawValue)
        return Image(systemName: "cellularbars", variableValue: value)
            .foregroundStyle(color)
            .imageScale(.large)
    }
}

@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    NavigationStack {
        List {
            AppleEffortScoreCell { _ in }
        }
    }
    .environment(\.locale, .init(identifier: "de"))
}
