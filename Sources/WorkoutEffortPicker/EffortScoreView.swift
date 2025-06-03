// Copyright (c) 2025 Ben Rudhart

import SwiftUI

/// Should be pushed to NavigationStack on watchOS
/// Should be modally presented on iOS
@available(iOS 18.0, watchOS 11.0, *)
struct EffortScoreView: View {
    @State private(set) var score: WorkoutEffortScore?
    let onSaveScore: (WorkoutEffortScore?) -> Void
    @Environment(\.dismiss) private var dismiss
    private var stackSpacing: CGFloat {
#if os(iOS)
        24
#else
        8
#endif
    }

    var body: some View {
        VStack(spacing: stackSpacing) {
            header
            EffortScorePicker(score: $score)

            currentValueLink
                .animation(.smooth.speed(0.7), value: score != nil) // animate when first selecting a score
        }
#if os(watchOS)
        .scenePadding(.horizontal)
#else
        .scenePadding()
#endif
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
                    .font(.body.weight(.medium))
#if os(watchOS)
                    .foregroundStyle(.black)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
#else
                    .labelStyle(.titleOnly)
#endif
                }
            )
            .disabled(score == nil)
            .tint(score == nil ? .tertiary : .primary)
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
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.07))
            .clipShape(.rect(cornerRadius: 12))
#else
            .padding(.vertical, score == nil ? 0 : 4)
            .background(.white.opacity(0.07))
            .clipShape(.buttonBorder)
#endif
    }

    @ViewBuilder
    private var currentValueOSLabel: some View {
#if os(iOS)
        if let score {
            LabeledContent {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
            } label: {
                EffortScoreLabel(score: score, isList: false)
            }
        } else {
            rateEffortText
        }
#else
        if let score {
            EffortScoreLabel(score: score, isList: false)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            rateEffortText
        }
#endif
    }

    private var rateEffortText: some View {
        Text("scoreView.rateEffort", bundle: .module)
            .font(.title3)
#if os(watchOS)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.7)
#else
            .lineLimit(1)
            .minimumScaleFactor(0.9)
#endif
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#if os(iOS)
@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    @Previewable @State var isPresented = true

    Text(verbatim: "Root View")
        .sheet(isPresented: $isPresented) {
            EffortScoreView(score: .skipped) { _ in }
        }
        .preferredColorScheme(.dark)
}
#else
@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    NavigationStack {
        EffortScoreView(score: nil) { _ in }
    }
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "de"))
}
#endif
