// Copyright (c) 2025 Ben Rudhart

import SwiftUI

/// Should be pushed to NavigationStack on watchOS
/// Should be modally presented on iOS
@available(iOS 18.0, watchOS 11.0, *)
struct EffortScoreView: View {
    @State private(set) var score: AppleEffortScore?
    let onSaveScore: (AppleEffortScore?) -> Void
    @Environment(\.dismiss) private var dismiss
    private var stackSpacing: CGFloat {
#if os(iOS)
        24
#else
        8
#endif
    }

    var body: some View {
#if os(iOS)
        NavigationStack {
            content
        }
#else
        content
#endif
    }

    private var content: some View {
        VStack(spacing: stackSpacing) {
            header
            EffortScorePicker(score: $score)
            currentValueLink
        }
        .scenePadding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BackgroundGradient(score: score))
        .toolbar(content: toolbar)
        .tint(.white)
        .foregroundStyle(.white)
#if os(watchOS)
        .sheet(isPresented: $isListPresented) {
            // important: needs to be placed below .tint(.white), otherwise the close button in sheet will be tinted
            EffortScoreList(score: $score)
        }
#endif
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
#if os(iOS)
        ToolbarItem(placement: .cancellationAction) {
            Button(
                action: { dismiss() },
                label: { Text("common.cancel", bundle: .module) }
            )
        }
#endif

        ToolbarItem(placement: .confirmationAction) {
            Button(
                action: {
                    onSaveScore(score)
                    dismiss()
                },
                label: {
                    Label {
                        Text("common.update", bundle: .module)
                    } icon: {
                        Image(systemName: "checkmark")
                    }
#if os(watchOS)
                    .foregroundStyle(.black)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
#else
                    .labelStyle(.titleOnly)
                    #endif
                }
            )
        }
    }

    @ViewBuilder
    private var header: some View {
#if os(iOS)
        Text("scoreView.rateEffort", bundle: .module)
            .font(.title)
            .fontWeight(.bold)
            .padding(.vertical, 50)
#else
        Spacer()
#endif
    }

    @State private var isListPresented = false
    private var currentValueLink: some View {
#if os(watchOS)
        Button {
            isListPresented = true
        } label: {
            currentValueLabel
        }
        .buttonStyle(.plain)
#else
        NavigationLink {
            EffortScoreList(score: $score)
        } label: {
            currentValueLabel
        }
#endif
    }

    private var currentValueLabel: some View {
        currentValueOSLabel
            .foregroundStyle(.white)
            .font(.body)
            .padding(.horizontal)
#if os(iOS)
            .padding(.vertical, 10)
            .background(.white.opacity(0.07))
            .clipShape(.rect(cornerRadius: 12))
#else
            .padding(.vertical)
            .background(.white.opacity(0.07))
            .clipShape(.buttonBorder)
#endif
    }

    @ViewBuilder
    private var currentValueOSLabel: some View {
#if os(iOS)
        LabeledContent {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        } label: {
            EffortScoreLabel(score: score)
        }
#else
        EffortScoreLabel(score: score)
            .frame(maxWidth: .infinity, alignment: .leading)
#endif
    }
}

#if os(iOS)
@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    @Previewable @State var isPresented = true

    Text("Root View")
        .sheet(isPresented: $isPresented) {
            EffortScoreView(score: .moderate1) { _ in }
        }
        .preferredColorScheme(.dark)
}
#else
@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    NavigationStack {
        EffortScoreView(score: .moderate1) { _ in }
    }
    .preferredColorScheme(.dark)
}
#endif
