// Copyright (c) 2025 Ben Rudhart

import SwiftUI

@available(iOS 18.0, watchOS 11.0, *)
struct EffortScoreList: View {
    @Binding var score: AppleEffortScore?

    var body: some View {
        List(selection: $score) {
            header

            ForEach(AppleEffortScoreSegment.allCases, content: section(segment:))

            noSelectionSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 60)
#if os(iOS)
        .background(BackgroundGradient(score: score))
        .listRowSeparator(.hidden)
#else
        .listStyle(.plain)
#endif
    }

    private var header: some View {
        Text("scoreList.header", bundle: .module)
            .listRowBackground(Color.clear)
        #if os(watchOS)
            .font(.caption)
        #else
            .font(.callout)
        #endif
    }

    private func section(segment: AppleEffortScoreSegment) -> some View {
        Section {
            ForEach(segment.scores, id: \.self) { score in
                label(score: score)
            }
        } header: {
            VStack(alignment: .leading) {
                Text(segment.localizedTitle, bundle: .module)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(segment.localizedDescription, bundle: .module)
#if os(watchOS)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fontWeight(.regular)
#endif
            }
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .textCase(.none)
        }
    }

    private var noSelectionSection: some View {
        Section {
            label(score: .skipped)
                .tag(AppleEffortScore.skipped)
        } header: {
            Divider()
                .listRowInsets(EdgeInsets())
                .padding(.top, -10)
        } footer: {
            Text("scoreList.noScore.footer", bundle: .module)
        }
    }

    private func label(score: AppleEffortScore) -> some View {
        LabeledContent {
            if score == self.score {
                Image(systemName: "checkmark")
            }
        } label: {
            EffortScoreLabel(score: score, isList: true)
        }
        .font(.title3.weight(.semibold))
        .foregroundStyle(.white)
#if os(iOS)
        .listRowBackground(
            VStack(spacing: 0) {
                Color.white.opacity(0.15)
                Rectangle()
                    .fill(.clear)
                    .frame(height: 1)
            }
        )
#endif
    }
}

@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    @Previewable @State var score: AppleEffortScore?
    @Previewable @State var isPresented = true
    Text(score?.segment?.localizedTitle ?? "common.skipped")
        .frame(maxHeight: .infinity)
        .background(BackgroundGradient(score: score))
        .sheet(isPresented: $isPresented) {
            EffortScoreList(score: $score)
        }
        .preferredColorScheme(.dark)
}
